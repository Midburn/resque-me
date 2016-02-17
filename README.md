# Midburn Tickets Queue

*Midburn Queue* is a ticket queuing system for the Midburn Organization.

###### About Midburn
Midburn is the fastest growing Burning Man regional in the world, taking place every May in the [Negev desert](https://en.wikipedia.org/wiki/Negev) of Israel. To learn more about the Midburn organization, [please read this](http://midburn.org/en-event/).

###### About the Solution
As a fast growing festival we 'suffer' for a high tickets demand, which made us to implement a **smart, transparent and equal as possible** solution.

The idea is simple: At the announced tickets sale date, participants are requested to navigate to a website (normally [queue.midburn.org](queue.midburn.org)) and wait for the queue to open. Once the queue is open, the site will automatically redirect the client to the register page to fill a basic form containing the user profile's email. On submission, as long as the queue is open, the requester will get in line for the next stage. Users in line, on their turn, will receive an email with a purchase link outside of the tickets queue implementation. *Important:* Getting in line does not guarantee a ticket. Tickets are been sold separately and the line will be closed once decided by the ticket sales admins.

###### Technology Stack

Midburn Queue web backend is based on [Sinatra](http://sinatrarb.com/). The queue database is based on [Resque](https://github.com/resque/resque) and [Redis](http://redis.io/).

### Application Routes/Configuration

As common with typical modern REST APIs, all requests are expected to include a `Content-Type: application/json` header, other requests may be rejected or just ignored.

In order to protect the API from scripts/robots, many of the apps configurations, routes & responses are defined using environment variables and may vary for each sale/deployment. This methodology allow us having open-source transparent solution while keep us protected from people who try to sneak into the queue. We have great ideas on how to better protect the queue, but the current solution was sufficient for our 2016 needs; nevertheless, [we would love your contribution!](./CONTRIBUTING.md)

##### POST /status

The `/status` methods will reply back to clients about the status of the queue. If the queue is close, the api will reply back with a `403` HTTP code (Forbidden).

Once the queue opens, the api will reply with the registration page.
```json
{
  "register_page": "register.html"
}
```

> **NOTICE:** the registration page may dynamically be set with the `REGISTER_FORM_URL` env variable. If not defined, the API will default to `register.html`

##### POST /register

In order to get into the queue, a web client will submit a web form. Typically, the form will include the following data:
```json
{
  "firstname": "John",
  "firstname": "Doe",
  "email": "john.doe@email.com"
}
```

If the queue is open, the requester's email will get into the queue. If the queue is close, the requester's email will be added to a special list of banned emails, since when using the web client, it should not be possible to fill out the form before the queue is open.

> **NOTICE:** the `POST /register` route is a dynamically changeable route defined by the `REGISTER_ROUTE` env variable. If not defined, the route will default to `/register`

##### Env Variables

```
# REDIS connection string
REDIS_URL="redis://localhost:6379/"

# AWS Credentials
AWS_ACCESS_KEY_ID="ABCDEFGHIJKLMNOPQRST"
AWS_SECRET_ACCESS_KEY="A1b2C3D4/e5-f6g7j2K2x2i13n1+0x21xp7Ux-sl"

# Queue lists will be stored on the following:
AWS_RESULTS_BUCKET="my-s3-bucket"
AWS_REGION="eu-west-1"

# Redis key to set the queue status
QUEUE_IS_OPEN_REDIS_KEY="queue_is_open"
```
For full list, see: [.env-example file!](./.env-example)

> **NOTICE:** This list might not be up to date. Nevertheless, .env-example should always be updated to the most recent env changes.

### Controlling the Queue

To control a running instance of the queue, simply execute one of the following [rake](https://github.com/ruby/rake) tasks.

> **NOTICE Heroku Users:** to execute a rake command on heroku, make sure you install [Heroku's Toolbelt](https://toolbelt.heroku.com/), login using: `heroku login` and then execute one of the above commands using: `heroku run`, For example: `heroku run bundle exec rake midburn:open_queue`

#### Frequently Used Tasks

```
bundle exec rake midburn:open_queue    # open the queue
bundle exec rake midburn:close_queue   # close the queue
bundle exec rake midburn:list          # Get List in CSV format
bundle exec rake midburn:reset         # Reset the queue completely
```

To get a full list of the available tasks, run `bundle exec rake -T midburn` and look for the

### Deployment

##### API Endpoints

This is a simple [Sinatra](http://sinatrarb.com/) application. Please follow Sinatra's recommendation on how to deploy the app ([The Sinatra Book](http://sinatra-org-book.herokuapp.com/#toc_41)).

For local development:
- Make sure `bundle` is installed (if not follow [bundler.io](http://bundler.io/)).
- Run `bundle install` to install dependencies.
- Run server using: `bundle exec puma -p 3000 -C puma.rb`

> **NOTICE**: use the `MIN_THREADS` & `MAX_THREADS` to set the number of puma threads to run on each api instance. For our need and since concurrency *was not* a concern with this simple solution & for our infrastructure, we found that each server may run very high (60+) amount of threads.

##### Redis Server

Queue implementation requires a running Redis server. Follow Redis instructions on how to install Redis instance [here](http://redis.io/topics/quickstart) (If you're on a mac and using [Homebrew](http://brew.sh), simply execute `brew install redis`).

Once installed, configure the `REDIS_URL` env variable to your server (for example: `REDIS_URL="redis://localhost:6379/"`)

##### Set Env Variables

For local development, we use the [dotenv gem](https://github.com/bkeepers/dotenv). copy `.env-example` to `.env` and configure the variables for your need.

For production needs, follow your environment's best practices.

### CONTRIBUTING

Please follow: [CONTRIBUTING.md](./CONTRIBUTING.md)

## LICENSE
The MIT License (MIT)

See: LICENSE file.
