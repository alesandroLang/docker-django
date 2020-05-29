#!/usr/bin/env bash

set -euo pipefail

source variables.sh

copyTemplateCodeByVersion() {
  rm -rf "$1"
  mkdir -p "$1"
  cp -R template/* "$1"
}

replaceBaseImageWithinTemplate() {
  echo "  using base image ${BASE_IMAGE}"

  sed "s/{{BASE_IMAGE}}/${BASE_IMAGE}/g" "$1/Dockerfile" > "$1/Dockerfile.tmp"
  mv "$1/Dockerfile.tmp" "$1/Dockerfile"
}

getPyPiPackageVersions() {
  curl --silent "https://pypi.org/pypi/$1/json" |
    jq -r '.releases | keys | .[]' |
    grep -vE '[0-9]([a-z]|rc)[0-9]' |
    sort --version-sort
}

replaceGunicornVersionWithinTemplate() {
  local GUNICORN_VERSION
  GUNICORN_VERSION=$(getPyPiPackageVersions 'gunicorn' | tail -1)

  echo "  using gunicorn ${GUNICORN_VERSION}"

  sed "s/{{GUNICORN_VERSION}}/${GUNICORN_VERSION}/g" "$1/Dockerfile" > "$1/Dockerfile.tmp"
  mv "$1/Dockerfile.tmp" "$1/Dockerfile"
}

replaceDjangoVersionWithinTemplate() {
  local DJANGO_VERSION
  DJANGO_VERSION=$(getPyPiPackageVersions 'Django' | grep "^$1" | tail -1)

  echo "  using django ${DJANGO_VERSION}"

  sed "s/{{DJANGO_VERSION}}/${DJANGO_VERSION}/g" "$1/Dockerfile" > "$1/Dockerfile.tmp"
  mv "$1/Dockerfile.tmp" "$1/Dockerfile"
}

replacePytzVersionWithinTemplate() {
  local PYTZ_VERSION
  PYTZ_VERSION=$(getPyPiPackageVersions 'pytz' | tail -1)

  echo "  using pytz ${PYTZ_VERSION}"

  sed "s/{{PYTZ_VERSION}}/${PYTZ_VERSION}/g" "$1/Dockerfile" > "$1/Dockerfile.tmp"
  mv "$1/Dockerfile.tmp" "$1/Dockerfile"
}

updateImageByVersion() {
  echo "updating image $1"
  copyTemplateCodeByVersion "$1"
  replaceBaseImageWithinTemplate "$1"
  replaceGunicornVersionWithinTemplate "$1"
  replaceDjangoVersionWithinTemplate "$1"
  replacePytzVersionWithinTemplate "$1"
}

for VERSION in "${VERSIONS[@]}"; do
  updateImageByVersion "${VERSION}"
done
