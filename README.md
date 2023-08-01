# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

2.7.8

* System dependencies:

- redis
- postgresql

* Database creation:

```
docker-compose run web bin/rails db:schema:load
docker-compose run web bin/rails db:seeds
```

Please note, the database log level in development mode is set to min_messages: debug5

If that creates too much of noise, please consider upgrading the min_message attribute to debug2 or debug3

* How to run the test suite

```
docker-compose run web bundle exec rspec .
```


