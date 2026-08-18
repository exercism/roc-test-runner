#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest manifest digest for ubuntu:24.04 from Docker Hub API..."

# 1. Get an anonymous bearer token for the Ubuntu repository
TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/ubuntu:pull" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 2. Request the manifest headers to extract the Docker-Content-Digest
DIGEST=$(curl -s -I -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.docker.distribution.manifest.list.v2+json" \
  -H "Accept: application/vnd.oci.image.index.v1+json" \
  "https://registry-1.docker.io/v2/library/ubuntu/manifests/24.04" | \
  grep -i '^docker-content-digest:' | awk '{print $2}' | tr -d $'\r')

if [[ -z "$DIGEST" ]]; then
  echo "❌ Error: Could not retrieve digest."
  exit 1
fi

echo "✅ Found latest digest: $DIGEST"

# 3. Update the Dockerfile (creating a temporary .bak file for Mac compatibility)
sed -i.bak -E "s|^FROM ubuntu:24.04@sha256:[a-f0-9]+|FROM ubuntu:24.04@$DIGEST|" Dockerfile
rm Dockerfile.bak

echo "✅ Dockerfile updated successfully!"
