#!/usr/bin/env bash

set -euo pipefail

source variables.sh

# default to 0 (do not push to registry) if the environment variable is not set
PUSH_TO_REGISTRY=${PUSH_TO_REGISTRY:-0}

buildImage() {
  local STABLE_TAG="${IMAGE}:$1"

  local GIT_COMMIT=$(git describe --always --dirty)
  local TODAY=$(date '+%Y%m%d')
  local UNIQUE_TAG="${IMAGE}:$1-${GIT_COMMIT}-${TODAY}"

  echo -e "\nbuilding image ${UNIQUE_TAG} ..."
  docker build --quiet --tag "${UNIQUE_TAG}" "$1"

  echo -e "\ntagging image ${UNIQUE_TAG} as ${STABLE_TAG} ..."
  docker tag "${UNIQUE_TAG}" "${STABLE_TAG}"

  if [[ $PUSH_TO_REGISTRY -eq 1 ]]; then
    echo -e "\npushing image ${STABLE_TAG} / ${UNIQUE_TAG} to registry ..."
    docker push "${UNIQUE_TAG}"
    docker push "${STABLE_TAG}"
  fi
}

echo "updating base image $BASE_IMAGE ..."
docker pull "$BASE_IMAGE"

for VERSION in "${VERSIONS[@]}"; do
  buildImage "$VERSION"
done

echo -e "\ntagging image ${IMAGE}:${VERSION_FOR_TAG_LATEST} as LATEST ..."
docker tag "${IMAGE}:${VERSION_FOR_TAG_LATEST}" "$IMAGE:LATEST"

if [[ $PUSH_TO_REGISTRY -eq 1 ]]; then
  echo -e "\npushing image ${IMAGE}:${VERSION_FOR_TAG_LATEST} / $IMAGE:LATEST to registry ..."
  docker push "$IMAGE:LATEST"
fi
