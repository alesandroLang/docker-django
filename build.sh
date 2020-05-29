#!/usr/bin/env bash

set -euo pipefail

source variables.sh

IMAGE='alang/django'

buildImage() {
  local TAG="$IMAGE:$1"
  echo "building image $TAG ..."
  docker build --quiet --tag "${TAG}" "$1"
}

echo "updating base image ${BASE_IMAGE} ..."
docker pull "$BASE_IMAGE"

for VERSION in "${VERSIONS[@]}"; do
  buildImage "${VERSION}"
done

echo "tagging image ${IMAGE}:${VERSION_FOR_TAG_LATEST} as LATEST ..."
docker tag "${IMAGE}:${VERSION_FOR_TAG_LATEST}" ${IMAGE}
