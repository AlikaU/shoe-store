require "faye/websocket"
require "eventmachine"
require "json"

class WebsocketClient
  def self.start
    Thread.new do # todo: graceful stop?
      EM.run do
        ws = Faye::WebSocket::Client.new("ws://localhost:8080/") # todo: configure path
        sleep 3
        p "Connecting to websocket server..." # todo: retry?
        ws.on :open do |event|
          p "websocket client: WebSocket connection opened"
        end
        ws.on :message do |event|
          puts "Received data: #{event.data}"
          data = JSON.parse(event.data)
          # todo: move business logic to services folder
          # todo: add more tables for other features as needed, e.g. inventory
          # note: could insert in batches if hitting the db too often is a concern
          Sale.create(model: data["model"], store: data["store"])
        end
        ws.on :error do |event|
          puts "websocket client error: #{event.message}"
          p "Error details: #{event.inspect}"
        end
      end
    end
  end
end
