# README

  

### Corrections in the implementation logic:

  

Request N4:

>  4. Parse and save the payloads to a Reservation model

  

There are multiple ways to save the payload from the endpoint. Following a cleaner approach, I decided to save payloads in RequestLogger model, and build Reservation & Guest models from parsed parameters.

  

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

### Run the server

```
docker-compose run web bundle exec rails c
```

Payload #1

```
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{ "reservation_code": "0012345678", "start_date": "2021-04-14", "end_date": "2021-04-18", "nights": 4, "guests": 4, "adults": 2, "children": 2, "infants": 0, "status": "accepted", "guest": { "first_name": "Wayne", "last_name": "Woodbridge", "phone": "639123456789", "email": "wayn_woodbridge@bnb.com" }, "currency": "AUD", "payout_price": "4200.00", "security_price": "500", "total_price": "4700.00" }' \
 http://0.0.0.0:13000/reservations
```

Payload #2
```
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{ "reservation": { "code": "11X12345678", "start_date": "2021-03-12", "end_date": "2021-03-16", "expected_payout_amount": "3800.00", "guest_details": { "localized_description": "4 guests", "number_of_adults": 2, "number_of_children": 2, "number_of_infants": 0 }, "guest_email": "wayne_woodbridge@bnb.com", "guest_first_name": "Wayne", "guest_last_name": "Woodbridge", "guest_phone_numbers": [ "639123456789", "639123456789" ], "listing_security_price_accurate": "500.00", "host_currency": "AUD", "nights": 4, "number_of_guests": 4, "status_type": "accepted", "total_paid_amount_accurate": "4300.00" } }' \
 http://0.0.0.0:13000/reservations
```



### Min / Max Thread usage

Depending on the production server (num of cores) we need to setup the ideal number of MIN/MAX threads which should be equal to number of cores of the server

