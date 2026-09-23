# Application image. It builds FROM the base image tag, so the base image must
# be built first; gaffer-exec enforces that ordering from the Makefile graph.
ARG BASE_IMAGE=gaffer-docker-build-graph-base:latest
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="gaffer-docker-build-graph-app"

RUN printf 'gaffer docker build graph: app layer\n' > /opt/app.txt \
    && cat /opt/base/payload.txt /opt/app.txt > /opt/app-payload.txt

CMD ["cat", "/opt/app-payload.txt"]
