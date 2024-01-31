#!/usr/bin/env bash

set -euox pipefail

install_appimages() {
  # Write appimages to /etc/appimages-install.json to install on first boot.
  jq -r '.appimages' config.json > /etc/appimages-install.json
}

install_flatpaks() {
  # Write flatpaks to /etc/flatpak.install to install on first boot.
  jq -r '.flatpaks[]' config.json > /etc/flatpak.install
}

install_github_releases() {
  for RELEASE in $(jq -c '.github_releases[]' config.json)
  do
    PROJECT=$(echo "$RELEASE" | jq -r '.project')
    ARCH=$(echo "$RELEASE" | jq -r '.arch')
    /tmp/github-release-install.sh "$PROJECT" "$ARCH"
  done
}

install_packages() {
  PACKAGES=$(jq -r '.packages.install | join(" ")' config.json)
  rpm-ostree install $PACKAGES
}

remove_packages() {
  PACKAGES=$(jq -r '.packages.remove | join(" ")' config.json)
  rpm-ostree override remove $PACKAGES
}

setup() {
  # Install desired appimages, flatpaks, & packages
  install_appimages
  install_flatpaks
  install_github_releases
  install_packages

  # Remove undesired packages
  remove_packages
}

setup