# E4-S6 Allow cross-origin requests

**Epic:** E4: Player Stats REST API (Back End)

**Epic goal:** a small JSON API stores players and their results.

As a front-end developer, I want CORS enabled, so that the React dev server can call the API.

**Acceptance criteria**

- `rack-cors` allows all origins and GET/POST/PUT/PATCH/DELETE/OPTIONS/HEAD.
- The React dev server proxies API calls to `http://0.0.0.0:3001`.
