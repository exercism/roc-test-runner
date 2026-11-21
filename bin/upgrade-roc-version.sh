#!/usr/bin/env bash
set -euo pipefail

# Usage: ./bin/upgrade-roc-version.sh [VERSION]
# With no version, select the newest numbered release, including prereleases.
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dockerfile="${repo_root}/Dockerfile"
github_api_url="${GITHUB_API_URL:-https://api.github.com}"
version_pattern='^[0-9]+\.[0-9]+\.[0-9]+([_-][A-Za-z0-9][A-Za-z0-9._-]*)?$'
rolling_pattern='(^|[-._])[Rr][Oo][Ll][Ll][Ii][Nn][Gg]($|[-._])'

if (( $# > 1 )) || { (( $# == 1 )) && [[ ! "$1" =~ $version_pattern || "$1" =~ $rolling_pattern ]]; }; then
    echo "Usage: $0 [VERSION] (for example, 0.1.0_RC1)" >&2
    exit 1
fi

github_api() {
    local -a curl_args=(--fail --silent --show-error --location
        --header 'Accept: application/vnd.github+json')
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        curl_args+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
    fi
    curl "${curl_args[@]}" "${github_api_url}/repos/roc-lang/roc/$1"
}

echo "Fetching Roc release information from GitHub API..."
if (( $# == 1 )); then
    release=$(github_api "releases/tags/$1")
else
    # /releases/latest excludes release candidates and can select old rolling builds.
    releases=$(github_api 'releases?per_page=100')
    release=$(jq -ce --arg pattern "$version_pattern" --arg rolling "$rolling_pattern" '
        first(.[] | select(.draft | not)
            | select(.tag_name | test($pattern))
            | select(.tag_name | test($rolling) | not))
        // error("no numbered Roc release found")
    ' <<< "$releases")
fi

roc_version=$(jq -er '.tag_name' <<< "$release")
if [[ ! "$roc_version" =~ $version_pattern || "$roc_version" =~ $rolling_pattern ]]; then
    echo "Error: invalid Roc release version: $roc_version" >&2
    exit 1
fi

asset_name="roc-linux_x86_64-${roc_version}.tar.gz"
roc_sha256=$(jq -er --arg name "$asset_name" '
    [.assets[] | select(.name == $name)]
    | if length == 1 then .[0].digest else error("expected exactly one AMD64 release archive") end
    | if type == "string" and test("^sha256:[0-9a-f]{64}$") then ltrimstr("sha256:")
      else error("missing or invalid SHA256 digest") end
' <<< "$release")

# Validate both pins before making a single edit, preserving macOS sed support.
if ! grep -q '^ARG ROC_VERSION=' "$dockerfile" || ! grep -q '^ARG ROC_SHA256=' "$dockerfile"; then
    echo "Error: Dockerfile must declare ROC_VERSION and ROC_SHA256." >&2
    exit 1
fi
sed -i.bak \
    -e "s/^ARG ROC_VERSION=.*/ARG ROC_VERSION=\"${roc_version}\"/" \
    -e "s/^ARG ROC_SHA256=.*/ARG ROC_SHA256=\"${roc_sha256}\"/" \
    "$dockerfile"
rm "${dockerfile}.bak"

echo "Updated Dockerfile to Roc ${roc_version} (${roc_sha256})."
