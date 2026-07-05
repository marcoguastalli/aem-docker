# aem-docker

Adobe AEM in Docker: Author + Publish + AEM SDK Dispatcher, with nginx terminating HTTPS on top (mimics the AEMaaCS CDN/TLS layer).

```
https://localhost (nginx, TLS) → dispatcher :8080 (SDK image, HTTP) → publish :4503 → author :4502
```

## Prerequisites

- **Docker Desktop** (or any Docker engine with the `docker compose` plugin). Give it at least **10 GB RAM** — Author and Publish each run with a 4 GB max heap.
- **The AEM as a Cloud Service SDK** — downloaded from the [Adobe Experience Cloud Software Distribution portal](https://experience.adobe.com/#/downloads) (requires an Adobe ID with AEM licensing). You need the SDK zip, which contains:
  - `aem-sdk-quickstart-<version>.jar` — the AEM runtime
  - `aem-sdk-dispatcher-tools-<v>-unix.sh` — the dispatcher tools self-extractor
- **A `license.properties` file** — comes with your AEM license (ask whoever manages your Adobe contract).

None of the Adobe artifacts are in this repo (they are licensed software); the setup below puts them in place.

## One-time setup

### 1. Clone the repo

```bash
git clone git@github.com:marcoguastalli/aem-docker.git
cd aem-docker
```

### 2. Extract the AEM SDK

Unzip the SDK download anywhere you like (it stays outside this repo), then extract the dispatcher tools inside it:

```bash
cd /path/to/aem-sdk-<version>
chmod +x aem-sdk-dispatcher-tools-<v>-unix.sh
./aem-sdk-dispatcher-tools-<v>-unix.sh     # creates dispatcher-sdk-<v>/
```

### 3. Load the dispatcher Docker image

The dispatcher tools ship the official dispatcher image as a tarball. Pick the one matching your CPU:

```bash
# Apple Silicon / ARM:
gunzip -c dispatcher-sdk-<v>/lib/dispatcher-publish-arm64.tar.gz | docker load
# Intel/AMD:
gunzip -c dispatcher-sdk-<v>/lib/dispatcher-publish-amd64.tar.gz | docker load
```

You should see: `Loaded image: adobe/aem-cs/dispatcher-publish:<v>`

### 4. Point the compose stack at the SDK

Edit `src/v1/.env`:

```bash
DISPATCHER_SDK=<relative path from src/v1 to dispatcher-sdk-<v>>
DISPATCHER_IMAGE=adobe/aem-cs/dispatcher-publish:<v>
```

`DISPATCHER_SDK` must be the path **relative to `src/v1/`** (or an absolute path). These are the only two lines to touch when you bump the SDK version later.

### 5. Seed the dispatcher configuration

The dispatcher config is Adobe-authored, so it is not tracked in this MIT repo — copy the SDK defaults once:

```bash
cp -R /path/to/dispatcher-sdk-<v>/src src/v1/dispatcher/src
```

Everything under `src/v1/dispatcher/src/` is yours to edit afterwards (filters, cache rules, vhosts).

### 6. Place the quickstart JAR and license

The same quickstart JAR becomes Author or Publish depending on its file name (the `p4502`/`p4503` suffix sets the port):

```bash
cp /path/to/aem-sdk-quickstart-<version>.jar src/v1/author/aem-author-p4502.jar
cp /path/to/aem-sdk-quickstart-<version>.jar src/v1/publish/aem-publish-p4503.jar
cp /path/to/license.properties src/v1/author/
cp /path/to/license.properties src/v1/publish/
```

### 7. Build the AEM images

```bash
cd src/v1
docker compose build author publish     # dispatcher + nginx need no build
```

## Run

```bash
cd src/v1
docker compose up -d
```

**Be patient on first start.** AEM installs itself on the first run — expect **10–15 minutes** before Author/Publish respond. Watch progress with:

```bash
docker compose ps                 # healthcheck flips to "healthy" when ready
docker compose logs -f publish    # or: author, dispatcher, nginx
```

The dispatcher logs `Waiting until publish is available` until Publish is up — that is normal, not an error.

Stop / start / reset:

```bash
docker compose stop               # stop containers, keep content
docker compose start              # start them again (fast, content persists)
docker compose down               # remove containers (content still persists)
rm -rf author/crx-quickstart publish/crx-quickstart   # nuke AEM content for a fresh install
```

AEM content survives restarts because `crx-quickstart/` is mounted from the host (`src/v1/author/crx-quickstart`, `src/v1/publish/crx-quickstart`). Logs land in `src/v1/logging/`.

## Endpoints

| URL | What | Notes |
|---|---|---|
| https://localhost | nginx → dispatcher → publish | Self-signed cert: accept the browser warning, or `curl -k` |
| http://localhost | nginx | 301-redirects to HTTPS |
| http://localhost:8080 | dispatcher directly (HTTP) | Bypasses nginx |
| http://localhost:4503 | Publish directly | |
| http://localhost:4502 | Author (login UI) | |

Default credentials: `admin` / `admin`. Override the password by exporting `AEM_PASSWORD` before `docker compose up` (used by the healthchecks too).

## Editing the dispatcher config

The dispatcher runs the config from `src/v1/dispatcher/src/` ("flexible mode"). After changing it:

```bash
cd src/v1/dispatcher
/path/to/dispatcher-sdk-<v>/bin/validate.sh src   # must pass
cd .. && docker compose restart dispatcher
```

## Troubleshooting

- **`https://localhost` returns 502** — the dispatcher backend (Publish) isn't up yet. Check `docker compose ps` and wait for `publish` to be healthy.
- **Dispatcher container exits on start** — usually a broken config; run the validator (above) and check `docker compose logs dispatcher`. Set `DISP_LOG_LEVEL=debug` in the environment for verbose output.
- **`docker compose config` errors about DISPATCHER_SDK** — the path in `src/v1/.env` doesn't resolve from `src/v1/`; fix the relative path.
- **Author/Publish never healthy** — check `docker compose logs author`; the most common cause is a missing/renamed JAR or missing `license.properties` in `src/v1/author/` / `src/v1/publish/`.
- **Port already in use** — something on your machine holds 80/443/4502/4503/8080; stop it or change the port mapping in `docker-compose.yml`.
