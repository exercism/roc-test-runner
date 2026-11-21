####
# This Dockerfile pins the exact Ubuntu image and AMD64 Roc compiler release.
# This ensures that minor commits to roc-test-runner won't accidently upgrade
# Ubuntu or Roc and break things. With pinned releases, we can safely upgrade
# the roc-test-runner and the Roc track exercises at the same time.
#
# Note: using the same Ubuntu image across many test runners reduces disk space
# so it's best to coordinate with the Exercism team before changing the digest.
#
# To upgrade Roc, run ./bin/upgrade-roc-version.sh [VERSION]
#
####
# Exercism deploys this test runner as a linux/amd64 image.
FROM ubuntu:26.04@sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c

ARG ROC_VERSION="0.1.0_RC1"
ARG ROC_SHA256="043c426ea85dcdbd427951eaed246f0c10c171d988f2598782233a6dae43379d"

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
RUN export ROC_FILENAME="roc-linux_x86_64-${ROC_VERSION}.tar.gz" \
    && export ROC_URL="https://github.com/roc-lang/roc/releases/download/${ROC_VERSION}/${ROC_FILENAME}" \
    && echo "Downloading ${ROC_URL}..." \
    && curl -fL -o "/tmp/${ROC_FILENAME}" "${ROC_URL}" \
    && echo "Verifying checksum..." \
    && echo "${ROC_SHA256}  /tmp/${ROC_FILENAME}" | sha256sum -c - \
    && echo "Extracting..." \
    && tar -xzf "/tmp/${ROC_FILENAME}" -C /opt/test-runner \
    && rm "/tmp/${ROC_FILENAME}" \
    && ln -s "/opt/test-runner/roc-linux_x86_64-${ROC_VERSION}/roc" /opt/test-runner/bin/roc \
    && bin/download-dependencies.sh

COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
