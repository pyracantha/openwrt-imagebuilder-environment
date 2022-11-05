FROM debian:11

RUN apt update \
    && apt -y install \
        build-essential \
        clang \
        flex \
        g++ \
        gawk \
        gcc-multilib \
        gettext \
        git \
        libncurses5-dev \
        libssl-dev \
        python3-distutils \
        rsync \
        unzip \
        zlib1g-dev
        curl \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh openwrt-imagebuilder-wrapper.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["imagebuilder"]
