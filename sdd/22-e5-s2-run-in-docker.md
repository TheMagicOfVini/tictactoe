# E5-S2 Run in Docker

**Epic:** E5: Developer Environment, Testing & Delivery

**Epic goal:** a developer can run, test and ship the app with minimal setup.

As a developer, I want a containerised environment, so that I don't have to install Ruby and Node on my machine.

**Acceptance criteria**

- `docker-compose up` builds a Ruby 2.6.1 image with Node 14 and exposes ports 3000 (front end), 3001 (API) and 8080 (code-server).
- `entrypoint/backend.sh` installs dependencies and starts Rails on `0.0.0.0:3001`; `entrypoint/frontend.sh` runs `npm install && npm start`.
- `entrypoint/codeserver.sh` starts a browser-based VS Code on port 8080, using the `PASSWORD` env var.
