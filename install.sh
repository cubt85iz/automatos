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
  # Get list of packages for installation.
  readarray -t PKGLIST < <(jq -r '.packages.install[]' config.json)

  # Install packages.
  if [ ${#PKGLIST[@]} -gt 0 ]; then
    rpm-ostree install "${PKGLIST[@]}"
  fi
}

remove_packages() {
  # Get list of objects containing packages for removal/replacement.
  readarray -t PKGLIST < <(jq -c '.packages.remove[]' config.json)

  if [ ${#PKGLIST[@]} -gt 0 ]; then
    for PKG in "${PKGLIST[@]}"; do
      # Get list of packages to remove from object
      readarray -t REMOVE < <(echo "$PKG" | jq -r '.remove[]')

      # Get replacement package
      REPLACE=$(echo "$PKG" | jq -r '.replace')

      # Replace package(s)
      if [ -n "$REPLACE" ] && [ "$REPLACE" != "null" ]; then
        rpm-ostree override remove "${REMOVE[@]}" --install "$REPLACE"

      # Remove package(s)
      else
        rpm-ostree override remove "${REMOVE[@]}"
      fi
    done
  fi
}

enable_repo() {
  REPO=${1:-}
  if [ -n "$REPO" ] && [ -f "$REPO" ]; then
    sed -i '0,/enabled=0/s//enabled=1/' /etc/yum.repos.d/"$REPO"
  else
    &>2 echo "[ERROR] No repository provided or provided repository not found."
    exit 1
  fi
}

install_repos() {
  for REPO in $(jq -r ".repos[]" config.json); do
    REPO_NAME=${REPO##*/}
    REPO_TYPE=${REPO_NAME##*.}
    if [ "$REPO_TYPE" == "rpm" ]; then
      rpm-ostree install $REPO
    else
      curl -L "$REPO" -o "/etc/yum.repos.d/$REPO_NAME"
    fi
  done
}

setup() {
  # Install third-party repositories.
  install_repos

  # Enable RPMFusion repository
  enable_repo rpmfusion-nonfree-nvidia-driver.repo

  # Remove undesired packages
  remove_packages

  # Install desired appimages, flatpaks, & packages
  install_github_releases
  install_packages
}

setup
