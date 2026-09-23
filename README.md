# Tic Tac Toe

Tic Tac Toe game with scoreboard. 
React front end, Ruby On Rails REST API backend.

Try it live at: https://obscure-springs-73090.herokuapp.com/
![alt text](https://i.imgur.com/ymupNbC.png "Website")

## Requirements

* Frontend: NodeJS
```
sudo apt install nodejs -y
```

* Backend: Ruby 2.5.3, Rails 5.2.1

```
\curl -sSL https://get.rvm.io | bash -s stable --ruby
rvm install 2.5.3
rvm use ruby-2.5.3
gem install rails
```

## Environment Variables

* `CORS_ORIGINS`: a comma-separated list of the origins that may call the API, for example `http://localhost:3000,https://example.com`. The app trims spaces around each origin and drops empty entries.
  * In development and in test, the app uses `http://localhost:3000` when `CORS_ORIGINS` is not set.
  * In production, `CORS_ORIGINS` is required. The app fails to boot with a clear error when it is not set or is blank.
  * For the live Heroku demo, set `CORS_ORIGINS` to the app's own URL (`https://obscure-springs-73090.herokuapp.com`), since the API and the React build are served from one origin.
* `ADMIN_TOKEN`: the admin credential for `PUT/PATCH /api/v1/players/:id` and `DELETE /api/v1/players/:id`. Send it in the `X-Admin-Token` header. A missing or wrong header returns 401.
  * When `ADMIN_TOKEN` is not set or is blank, every `PUT`, `PATCH` and `DELETE` request returns 401.
  * The game does not need it. The front end only reads players and posts results.
  * Example: `curl -X DELETE -H "X-Admin-Token: $ADMIN_TOKEN" http://localhost:3001/api/v1/players/1`

## Running With Docker
* Open three terminal windows, in the first run:
```
docker-compose up
```

* In the second terminal, navigate to /tictactoe/frontend
```
docker-compose exec web bash
./entrypoint/backend.sh
```

* In the third terminal, navigate to /tictactoe/frontend
```
docker-compose exec web bash
./entrypoint/frontend.sh
```

## Running Without Docker
* Open two terminal windows, in the first run:
```
git clone https://github.com/MiloTodt/tictactoe.git
cd tictactoe
cd backend
bundle install
rake db:setup
rails server -p 3001
```
![alt text](https://i.imgur.com/gSktGvX.png "Back")

* In the second terminal, navigate to /tictactoe/frontend
```
cd frontend
npm start
```
![alt text](https://i.imgur.com/Y3v6UwB.png "Front")

* This page should open in your browser
![alt text](https://i.imgur.com/ymupNbC.png "Website")
