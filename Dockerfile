####
# This Dockerfile pins the exact Ubuntu image and Roc compiler release.
# This ensures that minor commits to roc-test-runner won't accidently upgrade
# Ubuntu or Roc and break things. With pinned releases, we can safely upgrade
# the roc-test-runner and the Roc track exercises at the same time.
#
# Note: using the same Ubuntu image across many test runners reduces disk space
# so it's best to coordinate with the Exercism team before changing the digest.
#
# To upgrade to the latest Roc nightly, run ./bin/upgrade-roc-nightly.sh
#
####
FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b

ARG ROC_VERSION_DATE="2026-08-28"
ARG ROC_BUILD_ID="981de43"
ARG ROC_SHA256_AMD64="01f569e8218e4a47f0cef74204ba671c57c29e953d75860bf5b779243dee5487"
ARG ROC_SHA256_ARM64="f45e49cc0d1e127f0acc138857170c99bce3f56a463fe4fcefeef188c39ec5f4"
ARG TARGETARCH

RUN apt-get update --fix-missing \
    && apt-get upgrade --yes \
    && apt-get install --yes curl jq tar ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
COPY bin/download-dependencies.roc bin/download-dependencies.roc

RUN if [ "$TARGETARCH" = "arm64" ]; then \
        ROC_ARCH="arm64"; \
        ROC_SHA256=$ROC_SHA256_ARM64; \
    else \
        ROC_ARCH="x86_64"; \
        ROC_SHA256=$ROC_SHA256_AMD64; \
    fi \
    && export ROC_FILENAME="roc_nightly-linux_${ROC_ARCH}-${ROC_VERSION_DATE}-${ROC_BUILD_ID}.tar.gz" \
    && export ROC_URL="https://github.com/roc-lang/nightlies/releases/download/nightly-${ROC_VERSION_DATE}-${ROC_BUILD_ID}/${ROC_FILENAME}" \
    && echo "Downloading ${ROC_URL}..." \
    && curl -fL -o "/tmp/${ROC_FILENAME}" "${ROC_URL}" \
    && echo "Verifying checksum..." \
    && echo "${ROC_SHA256}  /tmp/${ROC_FILENAME}" | sha256sum -c - \
    && echo "Extracting..." \
    && tar -xzf "/tmp/${ROC_FILENAME}" -C /opt/test-runner \
    && rm "/tmp/${ROC_FILENAME}" \
    && ln -s "/opt/test-runner/roc_nightly-linux_${ROC_ARCH}-${ROC_VERSION_DATE}-${ROC_BUILD_ID}/roc" /opt/test-runner/bin/roc \
    && /opt/test-runner/bin/roc test bin/download-dependencies.roc

ENV PATH="$PATH:/opt/test-runner/bin"
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]

