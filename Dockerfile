FROM debian:10

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

ADD entrypoint.sh /entrypoint.sh 

ENTRYPOINT ["/entrypoint.sh"]
