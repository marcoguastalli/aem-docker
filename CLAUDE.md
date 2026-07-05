# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Docker setup for running Adobe AEM locally, mimicking the AEMaaCS delivery chain. There is no application code, package manager, test suite, or linter — everything is Docker/compose config and shell entrypoints.

Request flow: `https://localhost` (nginx, TLS termination) → `dispatcher` (AEM SDK dispatcher-publish image, HTTP) → `publish` :4503; `author` :4502 stands alone. All defined in `src/v1/docker-compose.yml`.

`src/nginx/src/v19/` is an older standalone nginx HTTPS experiment (static HTML demo), unrelated to the v1 stack. The v1 nginx layer (`src/v1/nginx/`) supersedes it.

## Required assets NOT in git (builds fail without them)

- `src/aem-sdk-<version>/` — the AEM SDK download: quickstart JAR + dispatcher tools self-extractor. Extract the dispatcher tools in place (`./aem-sdk-dispatcher-tools-<v>-unix.sh` → `dispatcher-sdk-<v>/`), then load the docker image: `gunzip -c dispatcher-sdk-<v>/lib/dispatcher-publish-arm64.tar.gz | docker load`
- `src/v1/author/` — `aem-author-p4502.jar` + `license.properties` (quickstart JAR renamed)
- `src/v1/publish/` — `aem-publish-p4503.jar` + `license.properties`

`src/v1/.env` pins two things: `DISPATCHER_SDK` (relative path to the extracted SDK — compose mounts its `lib/` into the dispatcher container) and `DISPATCHER_IMAGE` (the loaded image tag). Bumping the SDK version means updating `.env` and re-loading the image.

Gitignored at runtime: `crx-quickstart/`, `logging/`, `src/v1/dispatcher/cache/`, all `*.jar` and `license.properties`.

## Commands

All from `src/v1/`:

```bash
docker-compose build author publish   # dispatcher + nginx need no build
docker-compose up -d                  # full stack
docker-compose up -d dispatcher nginx # delivery layer only (dispatcher waits for publish)
```

Endpoints: https://localhost (nginx, self-signed cert — `curl -k`), http://localhost:8080 (dispatcher direct), Author :4502, Publish :4503. Admin password from `AEM_PASSWORD` env (default `admin`).

Validate dispatcher config after editing it:

```bash
cd src/v1/dispatcher && <sdk-dir>/dispatcher-sdk-<v>/bin/validate.sh src
```

## Architecture notes

- **Dispatcher** runs the official SDK image in "flexible mode", replicating what the SDK's `bin/docker_run.sh` does: project config mounted at `/mnt/dev/src` (source: `src/v1/dispatcher/src/`, seeded from SDK defaults; `opt-in/USE_SOURCES_DIRECTLY` enables flexible mode), SDK `lib/` mounted at `/usr/lib/dispatcher-sdk`, and two lib scripts mounted into `/docker_entrypoint.d/`. Its entrypoint waits for `AEM_HOST:AEM_PORT` itself — deliberately no `depends_on: publish`, so the delivery layer starts without AEM. `DISP_LOG_LEVEL=debug`/`REWRITE_LOG_LEVEL` can be set via environment for troubleshooting.
- **nginx** (`src/v1/nginx/`) terminates TLS on 443 with a self-signed localhost cert and proxies to `dispatcher:80`; port 80 is a 301 redirect to HTTPS. Regenerate certs with `openssl req -x509 -nodes -newkey rsa:2048 -subj '/CN=localhost' -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1' -days 3650 ...` into `src/v1/nginx/certs/`.
- **Author and Publish** images are near-identical (eclipse-temurin:11-jdk); each entrypoint (`run_author.sh` / `run_publish.sh`) combines `DEBUG_OPTS` + `JVM_OPTS` into `CQ_JVM_OPTS` and launches the quickstart JAR with runmodes `author|publish,localdev,dynamicmedia_scene7,nosamplecontent`. Keep both sides in sync when changing one.
- JPDA remote debugging: port 8502 (author) / 8503 (publish) — exposed in the images but not mapped in compose; add mappings to use them.
- Runmode mismatch: compose sets `AEM_RUNMODE` but the entrypoint scripts hardcode `-r ...` and ignore it — the env var currently has no effect.
- `src/v1/dispatcher/Dockerfile` is the old hand-rolled httpd:2.4 dispatcher, superseded by the SDK image and no longer referenced by compose.
