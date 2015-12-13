# VERSION         0.1.0
# DOCKER-VERSION  1.7.1
# DESCRIPTION:    CM Base Resource Image
# TO_BUILD:       tar -czh . | docker build -t cm/core -
# TO_RUN:         docker run cm/core cm --version

FROM ubuntu:14.04

COPY . /opt/cm/core
WORKDIR /opt/cm/core/bootstrap

RUN /opt/cm/core/bootstrap/bootstrap.sh
