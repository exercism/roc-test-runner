####
# This Dockerfile pins the exact Ubuntu image and AMD64 Roc compiler release.
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
# Exercism deploys this test runner as a linux/amd64 image.
FROM ubuntu:26.04@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7

ARG ROC_VERSION_DATE="2026-10-04"
ARG ROC_BUILD_ID="130536d"
ARG ROC_SHA256="893c86d2da0a4c390cbdbd4258ce45d686e5ec15b42eeeb811fd1ac44537714f"

RUN apt-get update --fix-missing \
    && apt-get upgrade --yes \
    && apt-get install --yes bash mawk curl jq tar ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
COPY dependencies/ dependencies/
COPY bin/download-dependencies.sh bin/is-platform-test bin/
ENV PATH="$PATH:/opt/test-runner/bin"
# Roc writes temporary build files here even with --no-cache.
# Downloaded packages are cached separately in /root/.cache/roc/packages.
ENV ROC_CACHE_DIR="/tmp/roc"

# Download and remove the archive in the same layer so it is not kept in the image.
RUN export ROC_FILENAME="roc_nightly-linux_x86_64-${ROC_VERSION_DATE}-${ROC_BUILD_ID}.tar.gz" \
    && export ROC_URL="https://github.com/roc-lang/nightlies/releases/download/nightly-${ROC_VERSION_DATE}-${ROC_BUILD_ID}/${ROC_FILENAME}" \
    && echo "Downloading ${ROC_URL}..." \
    && curl -fL -o "/tmp/${ROC_FILENAME}" "${ROC_URL}" \
    && echo "Verifying checksum..." \
    && echo "${ROC_SHA256}  /tmp/${ROC_FILENAME}" | sha256sum -c - \
    && echo "Extracting..." \
    && tar -xzf "/tmp/${ROC_FILENAME}" -C /opt/test-runner \
    && rm "/tmp/${ROC_FILENAME}" \
    && ln -s "/opt/test-runner/roc_nightly-linux_x86_64-${ROC_VERSION_DATE}-${ROC_BUILD_ID}/roc" /opt/test-runner/bin/roc \
    && bin/download-dependencies.sh

COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
