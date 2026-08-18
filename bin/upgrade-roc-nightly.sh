#!/usr/bin/env bash
set -euo pipefail

echo "Downloading the latest install_roc.sh script..."
SCRIPT=$(curl -sL https://roc-lang.org/install_roc.sh)

# 1. Parse the hardcoded variables from the script
ROC_DATE=$(grep '^VERSION_DATE=' <<< "$SCRIPT" | cut -d '"' -f 2)
ROC_BUILD=$(grep '^BUILD_ID=' <<< "$SCRIPT" | cut -d '"' -f 2)
ROC_AMD64=$(grep '^SHA_LINUX_X86_64=' <<< "$SCRIPT" | cut -d '"' -f 2)
ROC_ARM64=$(grep '^SHA_LINUX_ARM64=' <<< "$SCRIPT" | cut -d '"' -f 2)

# 2. Verify we actually found all four values
if [[ -z "$ROC_DATE" || -z "$ROC_BUILD" || -z "$ROC_AMD64" || -z "$ROC_ARM64" ]]; then
  echo "❌ Error: Failed to parse one or more variables from install_roc.sh."
  exit 1
fi

echo "✅ Found latest nightly: $ROC_DATE ($ROC_BUILD)"

# 3. Update the ARG values in the Dockerfile
sed -i.bak "s/^ARG ROC_VERSION_DATE=.*/ARG ROC_VERSION_DATE=\"$ROC_DATE\"/" Dockerfile
sed -i.bak "s/^ARG ROC_BUILD_ID=.*/ARG ROC_BUILD_ID=\"$ROC_BUILD\"/" Dockerfile
sed -i.bak "s/^ARG ROC_SHA256_AMD64=.*/ARG ROC_SHA256_AMD64=\"$ROC_AMD64\"/" Dockerfile
sed -i.bak "s/^ARG ROC_SHA256_ARM64=.*/ARG ROC_SHA256_ARM64=\"$ROC_ARM64\"/" Dockerfile
rm -f Dockerfile.bak

echo "✅ Dockerfile updated successfully!"
