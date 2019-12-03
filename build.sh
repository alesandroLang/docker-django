#!/usr/bin/env bash

set -euo pipefail

IMAGE='alang/django'

VERSIONS=()
VERSIONS+=('2.2')
VERSIONS+=('3.0')
LATEST='3.0'

buildImage() {
  local TAG="$IMAGE:$1"
  echo "building image $TAG ..."
  docker build --quiet --tag "${TAG}" "$1"
}

for INDEX in "${!VERSIONS[@]}"; do
  VERSION=${VERSIONS[$INDEX]}
  buildImage "${VERSION}"
done

echo "tagging image ${IMAGE}:${LATEST} as LATEST ..."
docker tag "${IMAGE}:${LATEST}" ${IMAGE}
