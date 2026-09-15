#!/usr/bin/env bash
set -euo pipefail

# Update the basic-cli platform and every package URL in
# bin/download-dependencies.roc to their latest stable GitHub releases.
#
# A stable release is neither a GitHub prerelease/draft nor a tag containing
# an alpha, beta, or release-candidate marker.

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
dependencies_file="${repo_root}/bin/download-dependencies.roc"
github_api_url="${GITHUB_API_URL:-https://api.github.com}"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command not found: $1" >&2
        exit 1
    fi
}

github_api() {
    local endpoint="$1"
    local -a curl_args=(--fail --silent --show-error --location
        --header 'Accept: application/vnd.github+json')

    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        curl_args+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
    fi

    curl "${curl_args[@]}" "${github_api_url}${endpoint}"
}

escape_sed_pattern() {
    sed 's/[][\\.^$*|]/\\&/g'
}

escape_sed_replacement() {
    sed 's/[\\&]/\\&/g'
}

require_command curl
require_command jq
require_command sed

if [[ ! -f "$dependencies_file" ]]; then
    echo "Error: dependency file not found: $dependencies_file" >&2
    exit 1
fi

work_file=$(mktemp "${dependencies_file}.XXXXXX")
trap 'rm -f "$work_file"' EXIT
cp "$dependencies_file" "$work_file"

updated_count=0
url_count=0

while IFS= read -r old_url; do
    ((url_count += 1))

    if [[ ! "$old_url" =~ ^https://github\.com/([^/]+)/([^/]+)/releases/download/[^/]+/[^/]+\.tar\.zst$ ]]; then
        echo "Error: unsupported package URL: $old_url" >&2
        exit 1
    fi

    repository="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"

    echo "Checking ${repository}..."
    releases=$(github_api "/repos/${repository}/releases?per_page=100")
    release=$(jq -ce '
        [ .[]
          | select(.draft | not)
          | select(.prerelease | not)
          | select(.tag_name | test("(^|[-._])(alpha|beta|rc)([-._0-9]|$)"; "i") | not)
        ]
        | first
        | if . == null then error("no stable release found") else . end
    ' <<< "$releases") || {
        echo "Error: no stable release found for ${repository}" >&2
        exit 1
    }

    tag_name=$(jq -er '.tag_name' <<< "$release")
    new_url=$(jq -er '
        [ .assets[] | select(.name | endswith(".tar.zst")) | .browser_download_url ]
        | if length == 1 then .[0]
          elif length == 0 then error("no .tar.zst asset found")
          else error("multiple .tar.zst assets found")
          end
    ' <<< "$release") || {
        echo "Error: expected exactly one .tar.zst asset in ${repository} release ${tag_name}" >&2
        exit 1
    }

    if [[ "$old_url" == "$new_url" ]]; then
        echo "${repository}: already at ${tag_name}"
        continue
    fi

    old_url_pattern=$(printf '%s' "$old_url" | escape_sed_pattern)
    new_url_replacement=$(printf '%s' "$new_url" | escape_sed_replacement)
    next_work_file=$(mktemp "${dependencies_file}.XXXXXX")
    sed "s#${old_url_pattern}#${new_url_replacement}#g" "$work_file" > "$next_work_file"
    mv "$next_work_file" "$work_file"

    echo "${repository}: ${tag_name}"
    ((updated_count += 1))
done < <(
    grep -oE 'https://github\.com/[^/[:space:]"]+/[^/[:space:]"]+/releases/download/[^/[:space:]"]+/[^/[:space:]"]+\.tar\.zst' "$dependencies_file"
)

if (( url_count == 0 )); then
    echo "Error: no GitHub package URLs found in $dependencies_file" >&2
    exit 1
fi

if (( updated_count == 0 )); then
    echo "All Roc packages are already up to date."
    exit 0
fi

mv "$work_file" "$dependencies_file"
trap - EXIT
echo "Updated ${updated_count} package URL(s) in bin/download-dependencies.roc."
