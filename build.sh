#!/usr/bin/env bash
set -ex

. .env

docker build -t $IMAGENAME:latest src