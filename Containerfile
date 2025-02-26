ARG BASE_IMAGE=${BASE_IMAGE:-ghcr.io/ublue-os/silverblue-nvidia}
ARG BASE_IMAGE_TAG=${BASE_IMAGE_TAG:-39-current}

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

ARG MACHINE=${MACHINE:-}

# Remove script that modifies user justfile.
RUN !test -f /etc/profile.d/ublue-os-just.sh || rm /etc/profile.d/ublue-os-just.sh

COPY etc/ /etc/
COPY usr/ /usr/
COPY *.sh /tmp/
COPY .config/$MACHINE /tmp/config.json

RUN pushd /tmp \
  && ./install.sh \
  && popd
