# E5-S1 Run locally without Docker

**Epic:** E5: Developer Environment, Testing & Delivery

**Epic goal:** a developer can run, test and ship the app with minimal setup.

As a developer, I want documented steps to start both apps, so that I can work on the code.

**Acceptance criteria**

- README covers installing Node and Ruby/Rails, `bundle install`, `rake db:setup`, `rails server -p 3001`, and `npm start` for the front end on port 3000.
- The Ruby version in the README is the version that the app uses. Every place in the README that names the version (the requirements line, `rvm install` and `rvm use`) shows the same version as `backend/.ruby-version`, the `ruby` line of `backend/Gemfile` and the `FROM ruby:` tag of `Dockerfile`. That version is 2.6.1.
- The `git clone` URL in the README is the URL of this repository (the `origin` remote), not the URL of the upstream fork.
- The repo carries no generated file. Git does not track `backend/db/development.sqlite3`, `backend/db/test.sqlite3`, `backend/log/development.log` or `backend/db/.seeds.rb.swp`, and `.gitignore` ignores `backend/db/*.sqlite3`, `backend/log/*` and `*.swp`. `rake db:setup` builds the databases.
- A back-end spec checks each of these rules, so the suite fails when the README or the git index drifts.
