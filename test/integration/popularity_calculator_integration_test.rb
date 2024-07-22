require "test_helper"
require "faye/websocket"
require "helpers/mock_websocket_server"
require "em-eventsource"


class PopularityCalculatorIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    # for the websocket client test attempt
    # @mock_server = MockWebSocketServer.new(8080)
    # Thread.new { @mock_server.run }
    # sleep 2 # give the server time to start, todo: better way?
    # @ws = Faye::WebSocket::Client.new("ws://localhost:8080/")
    # @message_count = 0
    # @calculator = PopularityCalculator.new

    # for the sse test attempt
    # @port = 3000
    # @url = "http://localhost:#{@port}/popularity"
  end

  def teardown
    @mock_server.stop
  end


  test "should serve welcome page" do
    get "/"
    assert_select "h1", "Welcome to the shoe store dashboard!"
  end


  # Attempt to test business logic + websocket client, by making a mock websocket server
  # test "should calculate sales percentage correctly" do
  #   # arrange
  #
  #   # act
  #   expected_report = [
  #     { model: "Model A", sales_percent: 100.0 } # todo: more test cases
  #   ]
  #
  #   sleep (5) # wait for 4x messages to be received, todo: don't sleep there should be better ways
  #   assert_equal expected_report, @calculator.calculate
  # end

  # Attempt to test SSE events + business logic
  # test "should send shoe popularity report" do
  #   # arrange
  #   Sale.create(model: "Model A", store: "Store A")
  #   Sale.create(model: "Model A",  store: "Store B")
  #   Sale.create(model: "Model B",  store: "Store C")
  #   Sale.create(model: "Model C",  store: "Store D")
  #
  #   # act: consume the SSE events on /popularity
  #   EM.run do
  #     source = EventMachine::EventSource.new(@url)
  #     source.message do |message|
  #       # this block is never reached..
  #       puts "new message #{message}"
  #     end
  #     source.error do |error|
  #       puts "sse error: #{error}" # I see 'sse error: Connection lost. Reconnecting.'
  #     end
  #     source.start # start listening
  #     loop do
  #       puts source.ready_state # I always see 0 (CONNECTING)
  #       sleep 5
  #     end
  #   end
  #   sleep 10 # todo: don't sleep, disconnect after X messages instead
  #
  #   # assert
  #   assert true
  # end
end
