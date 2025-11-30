ARG BASE_IMAGE=${BASE_IMAGE:-ghcr.io/ublue-os/silverblue-nvidia}
ARG BASE_IMAGE_TAG=${BASE_IMAGE_TAG:-41-current}

FROM scratch AS base
COPY / /

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

ARG MACHINE=${MACHINE:-}
ARG ROOT=${ROOT:-automatos}

COPY $ROOT/etc/ /etc/
COPY $ROOT/usr/ /usr/
COPY $ROOT/*.sh /tmp/
COPY .config/$MACHINE /tmp/config.json

RUN --mount=type-bind,from=base,src=/,dst=/base,Z \
    /base/install.sh
