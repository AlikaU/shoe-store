# Shoe store application

The application will monitor and adjust the inventory of shoes in real-time by processing incoming sales data via WebSocket, allowing the inventory department to keep track of shoe models' stock levels across various stores.

I used this project as an opportunity to get familiar with Ruby and Rails.

## Assumptions

I assume that each new incoming websocket event represents 1 sale. I assume that the 'inventory' field represents the number of shoes of that model *left* (not the number of shoes *sold*). Since the number of shoes sold isn't specified, I assume 1 pair was sold, and that the inventory fluctuations are due to some other events, as well as the toy example nature of this project.

## Features

### Shoe popularity report
We report % of sales for each shoe model.

I assume that each event coming from the provided program represents 1 sale (we assume 1 sale = 1 pair of shoes sold), and based on that I can report sales per model / total sales.

## Design decisions

- Used SSE events to send data to the UI, since the data goes in only one direction.
- Used MiniTest for testing, since this is a small project.
    - Integration tests cover as much of the logic as I could: processing new sales events, calculations business logic, model validation. Would have wanted to also cover the websocket client and the sent SSE events, but couldn't get it to work quickly.
    - Unit tests cover main business logic to make extra sure it is right.

# Running on host

## Pre-requisites
- Ruby 3.3.3

## Implementation notes
- Due to time constraints, there are todos left unimplemented.
- Feature set is very limited, but the project covers foundations on top of which more features can be built.



This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
