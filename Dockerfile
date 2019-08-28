ARG DEBIAN_SHA=21bdee09aac385973b3568feaf91c12bac8a9852caa04067ba3707dcd68b70e6
FROM debian:stretch-slim@sha256:${DEBIAN_SHA}

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
        python2.7-dev \
        python-pip \
        libffi-dev \
        sqlite3 \
        libssl-dev \
        python-virtualenv \
        libxslt1-dev

USER sydent
WORKDIR /home/sydent/
RUN set -ex\
    pip install --upgrade pip ;\
    pip install --upgrade setuptools; \
    pip install --user https://github.com/matrix-org/sydent/tarball/${SYDENT_VERSION};

COPY --chown=sydent:sydent default.conf /home/sydent/sydent.conf

VOLUME /home/sydent/data

EXPOSE 8090
CMD ["python", "-m", "sydent.sydent"]
