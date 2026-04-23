#!/bin/bash

FTS_VERSION=3.14.2

podman build --platform linux/amd64 \
  --build-arg VERSION=$FTS_VERSION \
  -t ${1:-localbuild/fts3-rest:latest} \
  -t ghcr.io/fnal-fife/fts3-rest:$FTS_VERSION \
  -f Containerfile .
