# film-ratings

[![CircleCI](https://circleci.com/gh/chrishowejones/blog-film-ratings.svg?style=svg)](https://circleci.com/gh/chrishowejones/blog-film-ratings)

This is an example Clojure web application written using the Duct
framework. This code is referenced by my blog on 'Building a Clojure
web application using Duct'.

## Developing

### Setup

When you first clone this repository, run:

```sh
lein duct setup
```

This will create files for local configuration, and prep your system
for the project.

### Environment

To begin developing, start with a REPL.

```sh
lein repl
```

Then load the development environment.

```clojure
user=> (dev)
:loaded
```

Run `go` to prep and initiate the system.

```clojure
dev=> (go)
:duct.server.http.jetty/starting-server {:port 3000}
:initiated
```

By default this creates a web server at <http://localhost:3000>.

When you make changes to your source files, use `reset` to reload any
modified files and reset the server.

```clojure
dev=> (reset)
:reloading (...)
:resumed
```

### Testing

Testing is fastest through the REPL, as you avoid environment startup
time.

```clojure
dev=> (test)
...
```

But you can also run tests through Leiningen.

```sh
lein test
```

## Running in production mode

First you need to build the uberjar for the application that will be
included in the docker container(s).

``` sh
lein do clean, uberjar
```

You will need to set the `DB_PASSWORD` environment variable to a
password for the postgresql database. You can then bring up the
postgresql, migrations and web application docker instances using
`docker-compose`.

``` sh
docker-compose up -d
```

This will use the `DB_PASSWORD` to create a postgresql database. This
database will use a volume mounted for the data in a directory
`./postgresdata`.

The `docker-compose` file starts two services:

    1. Postgres database - with a start up script to create an empty
    database if not already present.
    2. FilmApp - runs migrations (if required) & starts the web
    application listening on port 3000

## Examining logs

To see the logs from the docker compose services you can use:

``` sh
docker-compose logs
docker-compose logs --tail=20
docker-compose logs filmapp
```
The first command shows the entire logs for both services. The second
shows the last 20 lines of the log for both services. The last command
displays the logs for just the filmapp service.

## Stopping running docker compose

To stop the docker compose services run:

``` sh
docker-compose down
```

## Legal

Copyright © 2018 Chris Howe-Jones
