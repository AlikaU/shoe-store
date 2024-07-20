require "faye/websocket"
require "eventmachine"
require "json"

class WebsocketClient
  def self.start
    Thread.new do # todo: graceful stop?
      EM.run do
        ws = Faye::WebSocket::Client.new("ws://localhost:8080/") # todo: configure path

        p "Connecting to websocket server..."
        ws.on :message do |event|
          data = JSON.parse(event.data)

          # todo: add more tables for other features as needed, e.g. inventory
          # todo: could insert in batches if hitting the db too often is a concern
          Sale.create(model: data["model"], store: data["store"])
        end
      end
    end
  end
end
