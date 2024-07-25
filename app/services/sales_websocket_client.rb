require "faye/websocket"
require "eventmachine"
require "json"

# This class listens and receives incoming sales data from the websocket server.
class SalesWebsocketClient
  def self.start
    Thread.new do # todo: graceful stop?
      EM.run do
        shoe_events_address = ENV.fetch("SHOE_EVENTS_ADDRESS", "ws://localhost:8080/")
        ws = Faye::WebSocket::Client.new(shoe_events_address)
        sleep 3
        p "Connecting to websocket server..." # todo: retry
        ws.on :open do |event|
        end
        ws.on :message do |event|
          process_incoming_event(event)
        end
        ws.on :error do |event|
          puts "Websocket client error: #{event.message}. Please ensure the websocket server is running, then restart (todo: reconnect automatically)."
          exit(1)
        end
        ws.on :close do |event|
          puts "Websocket connection closed. Exiting."
          exit(0)
        end
      end
    end
  end

  private

  def self.process_incoming_event(event)
    begin
      data = JSON.parse(event.data)
    rescue JSON::ParserError => e
      p "Error parsing JSON: #{e.message}"
      return
    end

    result = SalesProcessor.new.process_incoming_sale(data)
    if !result[:success]
      p "Sale processing failed: #{result[:errors]}"
    end
  end
end
