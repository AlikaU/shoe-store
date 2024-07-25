require "faye/websocket"
require "eventmachine"
require "json"

class SalesWebsocketClient
  def self.start
    Thread.new do # todo: graceful stop?
      EM.run do
        shoe_events_address = ENV.fetch("SHOE_EVENTS_ADDRESS", "ws://localhost:8080/")
        ws = Faye::WebSocket::Client.new(shoe_events_address)
        sleep 3
        p "Connecting to websocket server..." # todo: retry?
        ws.on :open do |event|
        end
        ws.on :message do |event|
          process_incoming_event(event)
        end
        ws.on :error do |event|
          puts "websocket client error: #{event.message}"
          p "Error details: #{event.inspect}"
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
