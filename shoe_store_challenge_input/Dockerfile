FROM ruby:3.3-slim

WORKDIR /app

COPY bin/ ./bin/
COPY inventory.rb ./inventory.rb

RUN chmod +x ./bin/*
CMD ["bin/websocketd", "--port=8080", "ruby", "inventory.rb"]
