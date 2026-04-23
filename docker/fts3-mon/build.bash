#!/bin/bash

FTS_VERSION=3.14.2

podman build --platform linux/amd64 \
  --build-arg VERSION=$FTS_VERSION \
  -t ${1:-localbuild/fts3-mon:latest} \
  -t ghcr.io/fnal-fife/fts3-mon:$FTS_VERSION \
  -f Containerfile .
