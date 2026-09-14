# Ops Canvas

Ops Canvas is a deliberately read-only management companion for InterSystems
IRIS. It turns the first minutes of an operational task into a clear,
least-privilege briefing: what surface is involved, what the signed-in account
can see, and where an administrator should make an intentional change in the
Management Portal.

It is designed for the **Build Your Own Management Portal** contest, but the
project is a normal open-source IRIS module and runs on IRIS Community Edition
or IRIS for Health Community Edition.

## Why read-only first?

Management work is often split awkwardly between quick inspection and
high-impact changes. Ops Canvas keeps that boundary visible. It never stores
credentials, proxies sessions, or offers configuration mutations. Instead, it
uses the current authenticated IRIS session and reports an unavailable surface
when that session lacks access. No placeholder data is substituted.

## What it covers

| Portal area | Read-only capability | Data boundary |
| --- | --- | --- |
| Web apps and REST APIs | Lists REST-enabled applications in the current namespace. | Uses the Management API with the browser's session. |
| Permission management | Lists roles and enabled accounts visible to the caller. | No roles or users are changed. |
| Security and secrets | Lists TLS names, accessible X.509 aliases/expiry, and OAuth issuer configuration. | Never selects private keys, passwords, wallet values, tokens, or client secrets. |
| Task management | Lists scheduled task names, descriptions, and state. | No task action is implemented. |
| Operations | Lists bounded process metadata and mounted database capacity. | No process or database is modified. |
| Logs | Lists recent audit metadata only. | Audit descriptions and `EventData` are deliberately excluded. |

The app calls the documented endpoint
`/api/mgmnt/v1/:namespace/restapps`. See the official
[Management API reference](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GREST_reference).

## Run locally

Prerequisites: Docker Desktop and Git.

```bash
git clone https://github.com/akashjadon04/ops-canvas.git
cd ops-canvas
docker compose up -d --build
```

Open [http://localhost:52773/ops-canvas/](http://localhost:52773/ops-canvas/)
and sign in with the normal IRIS account appropriate for the surfaces you
intend to inspect. Ops Canvas does not add privileges. If a panel is
unavailable, use the minimum role that has the relevant access and refresh.

Supporting JSON endpoints:

```text
http://localhost:52773/ops-canvas/api/dashboard
http://localhost:52773/ops-canvas/api/overview
```

## Test

The repository builds the IRIS module and runs `%UnitTest` in GitHub Actions on
pushes and pull requests. Run the same verification locally with:

```bash
docker build --build-arg TESTS=1 --tag ops-canvas:test .
```

Or, from an IRIS terminal:

```objectscript
zn "IRISAPP"
zpm "test ops-canvas -v"
```

## Security model

| Concern | Ops Canvas behavior |
| --- | --- |
| Authentication | Reuses the existing same-origin IRIS session. |
| Authorization | Each source API/query evaluates under the caller's own privileges; no escalation is implemented. |
| Secret handling | Private keys, passwords, wallet values, token values, audit descriptions, and audit `EventData` are not selected or sent to the browser. |
| Mutation | No POST, PUT, PATCH, DELETE, task action, credential update, or process action is implemented. |
| Failure behavior | A denied source renders an unavailable state; other permitted panels still work. |

Recent IRIS versions require elevated security privileges for security APIs.
Ops Canvas relies on that native boundary rather than bypassing it; see
[Using Security APIs and Role Escalation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=ASECURITYAPI).

## Project structure

```text
src/OpsCanvas/Ui.cls         UI shell and current-session context
src/OpsCanvas/Overview.cls   Bounded read-only system, security, task, and audit queries
src/OpsCanvas/API.cls        CSP REST routes
tests/OpsCanvas/unittests/   %UnitTest coverage
module.xml                   ZPM module and /ops-canvas registration
```

## Roadmap

The next milestone is a demo capture from IRIS Community Edition and more
panel-specific tests. Any future mutation feature must be opt-in, individually
authorized, documented, and tested; it will not be silently added to this
inspection portal.
