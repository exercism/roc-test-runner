FROM ubuntu:24.04

RUN apt-get update --fix-missing
RUN apt-get upgrade --yes

# install packages required to run the tests
RUN apt-get install --yes wget jq coreutils libc-dev binutils \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
COPY bin/download-dependencies.roc bin/download-dependencies.roc

# download & install roc and the basic-cli platform
RUN wget -q -O roc.tar.gz https://github.com/roc-lang/roc/releases/download/alpha4-rolling/roc-linux_x86_64-alpha4-rolling.tar.gz \
    && mkdir /usr/lib/roc \
    && tar -xzf roc.tar.gz --directory /usr/lib/roc --strip-components=1 \
    && rm roc.tar.gz \
    && /usr/lib/roc/roc test bin/download-dependencies.roc

ENV PATH="$PATH:/usr/lib/roc"

COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
