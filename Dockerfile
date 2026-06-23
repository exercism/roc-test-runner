FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b

RUN apt-get update --fix-missing \
    && apt-get upgrade --yes \
    && apt-get install --yes curl jq \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
COPY bin/download-dependencies.roc bin/download-dependencies.roc

# download & install roc and the basic-cli platform
RUN curl --proto '=https' --tlsv1.2 -sSf https://roc-lang.org/install_roc.sh | ROC_CONTINUE_IF_STALE=y ROC_ADD_TO_PATH=n sh \
    && sh -c "ln -s /opt/test-runner/roc*/roc /opt/test-runner/bin/roc" \
    && /opt/test-runner/bin/roc test bin/download-dependencies.roc

ENV PATH="$PATH:/opt/test-runner/bin"

COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
