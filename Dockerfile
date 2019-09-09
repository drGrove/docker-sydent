ARG DEBIAN_SHA="sha256:21bdee09aac385973b3568feaf91c12bac8a9852caa04067ba3707dcd68b70e6"
FROM debian@${DEBIAN_SHA}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g 1000 sydent && useradd -u 1000 -g sydent -m sydent

# Git branch to build from
ARG SYDENT_VERSION=master

# use --build-arg REBUILD=$(date) to invalidate the cache and upgrade all
# packages
ARG REBUILD=1

RUN set -ex \
    && export DEBIAN_FRONTEND=noninteractive \
    && mkdir -p /var/cache/apt/archives \
    && touch /var/cache/apt/archives/lock \
    && apt-get clean \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
        bash \
        build-essential \
        git \
        libffi-dev \
        libssl-dev \
        libxslt1-dev \
        libyaml-cpp-dev \
        python-pip \
        python-virtualenv \
        python2.7-dev \
        sqlite3

USER sydent
WORKDIR /home/sydent/
RUN set -x \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc; \
    export PATH="$HOME/.local/bin:$PATH"; \
    pip install --upgrade --user pip; \
    $HOME/.local/bin/pip install --upgrade --user setuptools; \
    $HOME/.local/bin/pip install --upgrade --user pyasn1==0.4.7; \
    git clone --single-branch --branch ${SYDENT_VERSION} https://github.com/matrix-org/sydent; \
    cd sydent; \
    python setup.py install --user; \
    cp -r res ~/email.templates; \
    cp -r scripts ~/; \
    cd ~; \
    rm -rf sydent;

COPY --chown=sydent:sydent default.conf /home/sydent/sydent.conf

EXPOSE 8090
CMD ["python", "-m", "sydent.sydent"]
