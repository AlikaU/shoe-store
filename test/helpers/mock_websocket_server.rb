require "faye/websocket"
require "eventmachine"
require "em-websocket"

# Attempt to make a mock websocket server, but it never worked
class MockWebSocketServer
  def initialize(port)
    @port = port
    p "initializing mockserver with port #{@port}"
  end

  def run
    # binding.pry
    EM.run do
      # binding.pry
      @clients = []
      puts "inside EM.run" # todo: remove

      begin
        EM::WebSocket.run(host: "localhost", port: @port) do |ws|
          puts "inside EM::WebSocket.run" # todo: remove
          ws.onopen do |handshake|
            # binding.pry
            puts "WebSocket connection open"
            @clients << ws
            EM.add_periodic_timer(1) do
              puts "Sending data..."
              # binding.pry
              ws.send('{"model":"Model A","store":"Store A"}')
            end
          end

          ws.onclose do
            puts "Connection closed"
            @clients.delete(ws)
          end
        end
      rescue => e
        puts "Error: #{e.message}"
      end
    end
  end

  def stop
    EM.stop if EM.reactor_running?
  end
end
