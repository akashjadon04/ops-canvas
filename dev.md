# Developer notes

Ops Canvas is intentionally a small ObjectScript/CSP application with no
front-end build step. The container build loads the ZPM module and, when built
with `TESTS=1`, runs the module's `%UnitTest` suite.

```bash
docker compose up -d --build
docker compose exec iris iris session iris -U IRISAPP
```

From the IRIS prompt, reload the module or run its tests:

```objectscript
zpm "load /home/irisowner/dev -v"
zpm "test ops-canvas -v"
```

The application is registered at `/ops-canvas`; the JSON bootstrap endpoint is
`/ops-canvas/api/dashboard`. Keep additions read-only unless their Management
API authorization and failure behavior are documented and tested.
