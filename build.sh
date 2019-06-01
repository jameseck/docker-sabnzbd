#!/bin/sh
set -e

if [ "$1" == "--check" ] || [ "$1" == "-c" ]; then
  CHECKONLY=true
fi

# Latest stable release
URL=$(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases | jq -r "[ .[] | .assets[] | select(.name | test(\"SABnzbd-[0-9.]+-src.tar.gz\")) ] | first | .browser_download_url")

VERSION=$(echo $URL | cut -d\/ -f8)

git pull > /dev/null 2>&1
DOCKERFILE_VERSION=$(grep "^ARG SABNZBD_VERSION=" Dockerfile | cut -f2 -d\=)

if [ "${VERSION}" != "${DOCKERFILE_VERSION}" ]; then
  if [ "${CHECKONLY}" == "true" ]; then
    echo "There is a new version available"
    echo "Current version: ${DOCKERFILE_VERSION}"
    echo "Available version: ${VERSION}"
    exit 0
  fi

  echo "Updating Dockerfile with version ${VERSION}"
  sed -i -e "s/^\(ARG SABNZBD_VERSION=\).*$/\1${VERSION}/g" \
         -e "s|^\(ARG SABNZBD_URL=\).*$|\1${URL}|g" Dockerfile
  git add Dockerfile
  git commit -m "Bumping SABnzbd version to ${VERSION}"
  git push
  make minor-release
  exit -1
else
  make build
  make push
  echo "No change"
fi

# exit codes:
# 0 - no action
# -1 - new build pushed
# rest - errors
