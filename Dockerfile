# VERSION         0.1.0
# DOCKER-VERSION  1.7.1
# DESCRIPTION:    CM Base Resource Image
# TO_BUILD:       docker build -t cm/core .
# TO_RUN:         docker run cm/core cm --version

FROM ubuntu:14.04

ENV GEM_CM_DEV=1 GEM_CM_DIRECTORY=/opt/cm/core CM_CMD_VERSION=0.1.4

COPY . /opt/cm/core
WORKDIR /opt/cm/core/bootstrap

RUN /bin/bash -l -c "/opt/cm/core/bootstrap/bootstrap.sh base"
RUN /bin/bash -l -c "/opt/cm/core/bootstrap/bootstrap.sh git"
RUN /bin/bash -l -c "/opt/cm/core/bootstrap/bootstrap.sh ruby"
RUN /bin/bash -l -c "/opt/cm/core/bootstrap/bootstrap.sh cm"
RUN /bin/bash -l -c "/opt/cm/core/bootstrap/bootstrap.sh test"