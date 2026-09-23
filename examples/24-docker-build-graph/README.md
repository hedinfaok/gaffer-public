# Docker Build Graph

What this shows: building container images as a dependency graph, where the `app`
image builds `FROM` the `base` image tag and gaffer-exec schedules the two builds
in the correct order.

## What you'll learn

- Modeling image builds as Makefile targets with a real dependency edge.
- How gaffer-exec derives build order from that edge and runs independent work in parallel.
- Passing an image tag from one build to the next with `--build-arg`.
- Content-based caching of image build steps.
- How to skip the example gracefully when Docker is unavailable.

## Prerequisites

- gaffer-exec on your PATH
- Docker with a running daemon (`docker info` succeeds)
- Network access on the first run if the `debian:bookworm-slim` base is not cached locally

## Quick start

```bash
# Build the whole image graph (base, then app)
gaffer-exec --workspace-root . run make:build-all

# Inspect the resulting images
docker image inspect gaffer-docker-build-graph-base:latest
docker image inspect gaffer-docker-build-graph-app:latest

# Remove the example images
gaffer-exec --workspace-root . run make:clean
```

## Task graph

| Target | Depends on | What it does |
|--------|------------|--------------|
| `build-base` | - | Builds `base/Dockerfile` into the base image tag |
| `build-app` | `build-base` | Builds `app/Dockerfile` `FROM` the base image tag |
| `build-all` | `build-base`, `build-app` | Builds every image and prints a summary |
| `clean` | - | Removes both example images |

## How it works

The `app` image cannot be built until the `base` image exists, because its
Dockerfile starts with `FROM ${BASE_IMAGE}`. That single edge is the whole
dependency graph:

```
build-base
    │
build-app
    │
build-all
```

gaffer-exec reads the Makefile, builds the graph, and runs `build-base` before
`build-app`. Independent branches would run at the same time: if you added a
second image that also builds `FROM` base (for example a `worker` or a `test`
image), gaffer-exec would schedule it concurrently with `build-app` as soon as
`build-base` finished, rather than one after the other.

The image tag is a variable, so both Dockerfiles stay generic:

```make
build-app: build-base
	@docker build -t $(APP_IMAGE) --build-arg BASE_IMAGE=$(BASE_IMAGE) app
```

`app/Dockerfile` declares `ARG BASE_IMAGE` before its `FROM` line, which lets the
Makefile substitute the tag at build time. Because gaffer-exec caches by input
content, re-running `build-all` with unchanged Dockerfiles skips both builds.

## Expected output

```text
Sending build context to Docker daemon
...
✓ Built base image gaffer-docker-build-graph-base:latest
Sending build context to Docker daemon
...
✓ Built app image gaffer-docker-build-graph-app:latest
✓ All images built: gaffer-docker-build-graph-base:latest, gaffer-docker-build-graph-app:latest
```

## Testing

```bash
./test.sh
```

When Docker is available, the suite runs `make:build-all` and asserts both images
exist with `docker image inspect`. When Docker is unavailable it records
`blocked (environment: docker)`, runs `gaffer-exec --dry-run make:build-all`, and
exits 0 so a missing daemon is never treated as a failure.

## Troubleshooting

- **`Cannot connect to the Docker daemon`**: start Docker Desktop or the daemon, then confirm with `docker info`.
- **`pull access denied` or a network timeout**: the first build pulls `debian:bookworm-slim`; cache it once or use a base image already present locally.
- **`build-app` cannot find the base image**: build through `make:build-all` so `build-base` runs first, or run `make:build-base` on its own first.
- **Stale images after editing a Dockerfile**: run `make:clean` and rebuild.

## Next example

[19-cross-platform-builds](../19-cross-platform-builds/README.md) shows one Makefile graph that adapts to Linux, macOS, and Windows at build time.
