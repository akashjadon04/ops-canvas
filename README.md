# Ops Canvas

Ops Canvas is a small, read-only management companion for InterSystems IRIS.
It gives an administrator a clear starting point before a configuration change:

- a live inventory of REST-enabled applications from the IRIS Management API;
- a plain-language map of the Operator, Manager, and Security Manager privilege
  lanes; and
- the running namespace and IRIS version, visible in the same briefing.

The application deliberately does not write to IRIS configuration. It keeps the
existing Management Portal as the place where privileged changes happen, while
making the discovery and least-privilege decision easier to review first.

## Why this is useful

Management consoles often put discovery and mutation in the same dense surface.
That makes it easy to reach for an elevated account before understanding what
will be affected. Ops Canvas starts with the question an operator should answer
first: **which application surface am I about to manage, and which role should
own that decision?**

The REST application panel reads the documented Management API endpoint:

\`\`\`
GET /api/mgmnt/v1/:namespace/restapps
\`\`\`

The request runs in the browser using the administrator's current IRIS session.
Credentials are never copied into JavaScript, stored by the application, or
proxied by a second service.

## Features

- **Session-aware REST inventory**: Lists REST-enabled applications from IRIS'
  Management API, using the user's existing authenticated session.
- **Least-privilege briefing**: Explains the scopes represented by
  \`%Admin_Operate\`, \`%Admin_Manage\`, and \`%Admin_Secure\`.
- **Safe failure state**: If the signed-in user cannot query the API, the UI
  explains the required access instead of presenting stale or invented data.
- **No build toolchain for the UI**: The interface is delivered from the IRIS
  REST application as one responsive, dependency-free page.
- **Unit coverage**: Tests verify the role lanes, management endpoint
  construction, and rendered application shell.

## Run locally

Prerequisites:

- Docker Desktop
- Git

\`\`\`bash
git clone <your-fork-url> ops-canvas
cd ops-canvas
docker compose up -d --build
\`\`\`

Open [http://localhost:52773/ops-canvas/](http://localhost:52773/ops-canvas/)
and sign in with an IRIS user that is permitted to view the target namespace.

The backing JSON endpoint is available at:

\`\`\`
http://localhost:52773/ops-canvas/api/dashboard
\`\`\`

## Test

From an IRIS terminal in the container:

\`\`\`objectscript
zn "IRISAPP"
zpm "test ops-canvas"
\`\`\`

Or run the tests during a container build by building with \`TESTS=1\`.

## Security model

Ops Canvas is intentionally an inspection surface, not an alternate privileged
control plane.

| Capability | How it is handled |
| --- | --- |
| Application inventory | Read directly from the Management API with the current session |
| Credentials | Never persisted, forwarded, or displayed |
| Configuration writes | Not implemented |
| Authorization | Enforced by IRIS for the current Management API request |
| Failures | Shown as access guidance; no mock data is substituted |

## Project structure

\`\`\`
src/OpsCanvas/Portal.cls       Dashboard data and UI renderer
src/OpsCanvas/API.cls          CSP REST routes
tests/OpsCanvas/unittests/     %UnitTest coverage
module.xml                     ZPM module and /ops-canvas application registration
\`\`\`

## Roadmap

The next deliberately scoped additions are a role-aware database capacity
briefing and a task-schedule preview. Both will remain read-only until their
management API behavior and authorization boundaries have been validated.
