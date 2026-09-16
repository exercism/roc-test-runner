#!/usr/bin/env bash
set -euo pipefail

echo "Fetching the latest release information from GitHub API..."
LATEST_RELEASE=$(curl -sL https://api.github.com/repos/roc-lang/nightlies/releases/latest)
TAG_NAME=$(jq -r '.tag_name' <<< "$LATEST_RELEASE")

if [[ -z "$TAG_NAME" || "$TAG_NAME" == "null" ]]; then
  echo "❌ Error: Failed to fetch the latest release tag."
  exit 1
fi

# TAG_NAME format: nightly-YYYY-MM-DD-BUILD_ID

# 1. Extract the Build ID (strip everything up to the last hyphen)
ROC_BUILD="${TAG_NAME##*-}"

# 2. Extract the Date (strip the first component, then strip the last component)
ROC_DATE="${TAG_NAME#*-}"     # Strips "nightly-"
ROC_DATE="${ROC_DATE%-*}"     # Strips "-BUILD_ID"

echo "Extracting SHA256 checksums from release data..."
ROC_SHA256_RAW=$(jq -r '.assets[] | select(.name | contains("linux_x86_64") and endswith(".tar.gz")) | .digest // ""' <<< "$LATEST_RELEASE")

# Strip the "sha256:" prefix
ROC_SHA256=${ROC_SHA256_RAW#sha256:}

if [[ -z "$ROC_SHA256" ]]; then
  echo "❌ Error: Failed to extract the linux_x86_64 SHA256 checksum from GitHub API."
  exit 1
fi

echo "✅ Found latest nightly: $ROC_DATE ($ROC_BUILD)"

# Update the ARG values in the Dockerfile
sed -i.bak "s/^ARG ROC_VERSION_DATE=.*/ARG ROC_VERSION_DATE=\"$ROC_DATE\"/" Dockerfile
sed -i.bak "s/^ARG ROC_BUILD_ID=.*/ARG ROC_BUILD_ID=\"$ROC_BUILD\"/" Dockerfile
sed -i.bak "s/^ARG ROC_SHA256=.*/ARG ROC_SHA256=\"$ROC_SHA256\"/" Dockerfile
rm Dockerfile.bak

echo "✅ Dockerfile updated successfully!"
