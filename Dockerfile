FROM debian:latest

RUN apt-get update --fix-missing
RUN apt-get upgrade --yes

# install packages required to run the tests
RUN apt-get install --yes wget jq coreutils libc-dev binutils \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
COPY bin/download-basic-cli.roc bin/download-basic-cli.roc

# download & install roc and the basic-cli platform
RUN wget -q -O roc.tar.gz https://github.com/roc-lang/roc/releases/download/nightly/roc_nightly-linux_x86_64-latest.tar.gz \
    && mkdir /usr/lib/roc \
    && tar -xvz -f roc.tar.gz --directory /usr/lib/roc --strip-components=1 \
    && rm roc.tar.gz \
    && /usr/lib/roc/roc test bin/download-basic-cli.roc
ENV PATH="$PATH:/usr/lib/roc"

COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
