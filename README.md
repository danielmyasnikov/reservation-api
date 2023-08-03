# README

  

### Corrections in the implementation logic:

  

Request N4:

>  4. Parse and save the payloads to a Reservation model

  

There are multiple ways to save the payload from the endpoint. I decided to save payloads in RequestLogger model, and build Reservation & Guest models from parsed parameters.

  

### Ruby version

  

2.7.8

  

### System dependencies:

 
- postgresql
- lefthooks

  
### Logging & Debugging

  

Please note, the database log level in development mode is set to min_messages to debug5, which logs all the information from the database.

  

If that creates too much of noise, please consider upgrading the min_message attribute to debug2 or debug3.

  

### Installation:

Ensure docker daemon is running and run:

```
docker-compose build
docker-compose run web bin/rails db:create
docker-compose run -e RAILS_ENV=test web bin/rails db:create
docker-compose run web bin/rails db:migrate
```

  

* How to run the test suite

  

```
docker-compose run web bundle exec rspec .
```

### Development

Install githooks integration via lefthook

`lefthook install`

```
docker-compose run web bundle exec rails c
```

