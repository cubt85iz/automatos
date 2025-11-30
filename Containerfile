ARG BASE_IMAGE=${BASE_IMAGE:-ghcr.io/ublue-os/silverblue-nvidia}
ARG BASE_IMAGE_TAG=${BASE_IMAGE_TAG:-41-current}

FROM scratch AS base
COPY / /

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

ARG ROOT=${ROOT:-automatos}

COPY $ROOT/etc/ /etc/
COPY $ROOT/usr/ /usr/

RUN --mount=type-bind,from=base,src=/,dst=/base,Z \
    /base/install.sh
