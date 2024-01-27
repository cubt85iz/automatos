#!/usr/bin/env bash

set -euox pipefail

install_appimages() {
  for APPIMAGE in $(jq -c '.appimages[]' config.json)
  do
    NAME=$(echo "$APPIMAGE" | jq -r '.name')
    SOURCE=$(echo "$APPIMAGE" | jq -r '.source')
    PATTERN=$(echo "$APPIMAGE" | jq -r '.pattern')

    # Query the Github REST API for releases.
    if [ "${PATTERN-}" == "null" ]; then
      ASSET_URL=$(curl -s -X GET "https://api.github.com/repos/$SOURCE/releases/latest" | jq -r '.assets | map(select(.name | contains("AppImage"))) | first | .browser_download_url')
    else
      ASSET_URL=$(curl -s -X GET "https://api.github.com/repos/$SOURCE/releases" | jq --arg PATTERN "$PATTERN" -r 'map(select(.name | test($PATTERN))) | first | .assets | map(select(.name | contains("AppImage"))) | first | .browser_download_url')
    fi

    # Download AppImage to /usr/local/bin
    if [ -n "${ASSET_URL-}" ]; then
      mkdir -p /var/usrlocal/bin
      curl -sSL "$ASSET_URL" -o "/usr/local/bin/$NAME"
      chmod +x "/usr/local/bin/$NAME"
    else
      echo "Unable to determine asset url for $NAME."
      exit 1
    fi
  done
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