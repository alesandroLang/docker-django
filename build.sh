#!/usr/bin/env bash

set -euo pipefail

IMAGE='alang/django'

VERSIONS=()
VERSIONS+=('1.8')
VERSIONS+=('1.10')
VERSIONS+=('1.11')
LATEST='1.11-python3'

buildImageByTagAndPath(){
	local TAG="$IMAGE:$1"
	echo "building image $TAG ..."
	docker build --quiet --tag ${TAG} $2
}

buildImageByVersion(){
	buildImageByTagAndPath "$1-python2" "$1/python2"
	buildImageByTagAndPath "$1-python2-onbuild" "$1/python2/onbuild"
	buildImageByTagAndPath "$1-python3" "$1/python3"
	buildImageByTagAndPath "$1-python3-onbuild" "$1/python3/onbuild"
}

for INDEX in "${!VERSIONS[@]}"; do
	VERSION=${VERSIONS[$INDEX]}
	buildImageByVersion ${VERSION}
done

docker tag "${IMAGE}:${LATEST}" ${IMAGE}
