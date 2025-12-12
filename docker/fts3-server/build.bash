podman buildx build --platform linux/amd64 -t ${1:-localbuild/fts3-server:latest} -f Containerfile .
