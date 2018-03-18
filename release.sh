#!/usr/bin/env bash
set -ex

. .env

VERSION=$(<VERSION)

echo "Image: $IMAGENAME"
echo "Version: $VERSION"

docker tag $IMAGENAME:latest $IMAGENAME:$VERSION

docker push $IMAGENAME:latest
docker push $IMAGENAME:$VERSION