#!/bin/bash

FTS_VERSION=3.14.3
IMAGE_VERSION=0.2.0

podman build --platform linux/amd64 \
  --build-arg FTS_VERSION=$FTS_VERSION \
  --build-arg IMAGE_VERSION=$IMAGE_VERSION \
  -t ghcr.io/fnal-fife/fts3-mon:$FTS_VERSION-$IMAGE_VERSION \
  -f Containerfile .
