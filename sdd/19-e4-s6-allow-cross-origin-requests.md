# E4-S6 Allow cross-origin requests

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As a front-end developer, I want CORS enabled, so that the React dev server can call the API.

**Acceptance criteria**

- The app reads the list of allowed origins from `ENV['CORS_ORIGINS']`, a comma-separated list. The app trims the spaces around each origin and drops each empty entry.
- In development and in test, the app uses `http://localhost:3000` as the default origin when `CORS_ORIGINS` is not set.
- In production, `CORS_ORIGINS` is required. The app fails to boot and shows a clear error message when the variable is not set or is blank in production.
- The app never uses `*` as a default origin.
- `rack-cors` allows GET, POST, PUT, PATCH, DELETE, OPTIONS and HEAD for each allowed origin.
- A request from an allowed origin gets the CORS headers, including `Access-Control-Allow-Origin`. A request from another origin gets no `Access-Control-Allow-Origin` header.
- The React dev server proxies API calls to `http://0.0.0.0:3001`.
