# aem-docker
Adobe AEM in Docker: Author + Publish + AEM SDK Dispatcher, with nginx terminating HTTPS on top (mimics the AEMaaCS CDN/TLS layer).

```
https://localhost (nginx, TLS) → dispatcher :8080 (SDK image, HTTP) → publish :4503 → author :4502
```

### One-time setup
1. Download the AEM SDK and place it under `src/aem-sdk-<version>/` (not tracked by git).
2. Extract the dispatcher tools: `./aem-sdk-dispatcher-tools-<v>-unix.sh`
3. Load the dispatcher image:
   `gunzip -c dispatcher-sdk-<v>/lib/dispatcher-publish-arm64.tar.gz | docker load`
4. Point `src/v1/.env` at the extracted SDK folder (one line to update per SDK bump).
5. Copy the quickstart JAR + `license.properties` into `src/v1/author/` (as `aem-author-p4502.jar`) and `src/v1/publish/` (as `aem-publish-p4503.jar`).

### Build
- `cd src/v1`
- `docker-compose build author publish`

### Run
- `docker-compose up -d`
- `docker-compose stop` / `docker-compose start`

### Play
- https://localhost — nginx → dispatcher → publish (self-signed cert, use `curl -k`)
- http://localhost:8080 — dispatcher directly (HTTP)
- http://localhost:4502 / :4503 — author / publish directly

### Dispatcher config
Lives in `src/v1/dispatcher/src/` (flexible mode, seeded from the SDK defaults). Validate after changes:
- `cd src/v1/dispatcher && <sdk>/dispatcher-sdk-<v>/bin/validate.sh src`
