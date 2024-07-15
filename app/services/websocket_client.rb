require "faye/websocket"
require "eventmachine"
require "json"

class WebsocketClient
  def self.start
    Thread.new do # todo: graceful stop?
      EM.run do
        ws = Faye::WebSocket::Client.new("ws://localhost:8080/") # todo: configure path

        ws.on :message do |event|
          p JSON.parse(event.data)
        end
      end
    end
  end
end
