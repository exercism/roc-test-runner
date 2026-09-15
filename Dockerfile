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

ARG ROC_VERSION_DATE="2026-09-15"
ARG ROC_BUILD_ID="fe09c42"
ARG ROC_SHA256_AMD64="49acbf36a216b05ac7ce48996bc25b8ecc71ac01e2b58a4f5fac7e8f569b10d7"
ARG ROC_SHA256_ARM64="c5abdc334af76b488ce84c83dfef8ac52d0ee8e869dfc081ad392275c34b9618"
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

