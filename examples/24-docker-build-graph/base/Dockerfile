# Base image for the docker-build-graph example.
# The app image declares this image as its parent, so build it first.
FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="gaffer-docker-build-graph-base"

RUN mkdir -p /opt/base \
    && printf 'gaffer docker build graph: base layer\n' > /opt/base/payload.txt

CMD ["cat", "/opt/base/payload.txt"]
