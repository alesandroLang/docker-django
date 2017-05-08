#!/usr/bin/env bash

set -euo pipefail

VERSIONS=()
VERSIONS+=('1.8')
VERSIONS+=('1.10')
VERSIONS+=('1.11')

copyTemplateCodeByVersion() {
	rm -rf $1
	mkdir -p $1/python2
	mkdir -p $1/python3
	cp -R template/* $1/python2/
	cp -R template/* $1/python3/
}

replaceImageVersionWithinTemplate() {
	sed -i '' "s/{{IMAGE_VERSION}}/$1/g" $1/python2/Dockerfile
	sed -i '' "s/{{IMAGE_VERSION}}/$1/g" $1/python3/Dockerfile
	sed -i '' "s/{{IMAGE_VERSION}}/$1/g" $1/python2/onbuild/Dockerfile
	sed -i '' "s/{{IMAGE_VERSION}}/$1/g" $1/python3/onbuild/Dockerfile
}

replacePythonVersionWithinTemplate() {
	sed -i '' "s/{{PYTHON_VERSION}}/2/g" $1/python2/Dockerfile
	sed -i '' "s/{{PYTHON_VERSION}}/3/g" $1/python3/Dockerfile
	sed -i '' "s/{{PYTHON_VERSION}}/2/g" $1/python2/onbuild/Dockerfile
	sed -i '' "s/{{PYTHON_VERSION}}/3/g" $1/python3/onbuild/Dockerfile
}

getPyPiPackageVersions() {
	 curl --silent "https://pypi.python.org/pypi/$1/json" \
	 | grep '^        "[0-9].*\[$' \
	 | cut -d '"' -f2 \
	 | grep -vE '[0-9]([a-z]|rc)[0-9]' \
	 | sort --version-sort
}

replaceGunicornVersionWithinTemplate() {
	local LATEST=$(getPyPiPackageVersions 'gunicorn' | tail -1)
	echo "  using gunicorn ${LATEST}"
	sed -i '' "s/{{GUNICORN_VERSION}}/$LATEST/g" $1/python2/Dockerfile
	sed -i '' "s/{{GUNICORN_VERSION}}/$LATEST/g" $1/python3/Dockerfile
}

replaceDjangoVersionWithinTemplate() {
	local LATEST=$(getPyPiPackageVersions 'Django' | grep "^$1" | tail -1)
	echo "  using django ${LATEST}"
	sed -i '' "s/{{DJANGO_VERSION}}/$LATEST/g" $1/python2/Dockerfile
	sed -i '' "s/{{DJANGO_VERSION}}/$LATEST/g" $1/python3/Dockerfile
}

replacePytzVersionWithinTemplate() {
	local LATEST=$(getPyPiPackageVersions 'pytz' | tail -1)
	echo "  using pytz ${LATEST}"
	sed -i '' "s/{{PYTZ_VERSION}}/$LATEST/g" $1/python2/Dockerfile
	sed -i '' "s/{{PYTZ_VERSION}}/$LATEST/g" $1/python3/Dockerfile
}

updateImageByVersion() {
	echo "updating image $1"
	copyTemplateCodeByVersion $1
	replaceImageVersionWithinTemplate $1
	replacePythonVersionWithinTemplate $1
	replaceGunicornVersionWithinTemplate $1
	replaceDjangoVersionWithinTemplate $1
	replacePytzVersionWithinTemplate $1
}

for INDEX in "${!VERSIONS[@]}"; do
	VERSION=${VERSIONS[$INDEX]}
	updateImageByVersion ${VERSION}
done
