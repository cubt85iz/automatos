#!/usr/bin/env bash

set -euox pipefail

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
  install_github_releases
  install_packages

  # Remove undesired packages
  remove_packages
}

setup