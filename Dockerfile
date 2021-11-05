FROM debian:11

RUN apt update \
    && apt -y install \
        build-essential \
        libncurses5-dev \
        libncursesw5-dev \
        zlib1g-dev \
        gawk \
        git \
        gettext \
        libssl-dev \
        xsltproc \
        wget \
        unzip \
        python \
        python3 \
        curl \
        rsync \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh openwrt-imagebuilder-wrapper.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["imagebuilder"]
