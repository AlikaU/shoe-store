require "test_helper"
require "faye/websocket"
require "helpers/mock_websocket_server"
require "em-eventsource"


class PopularityCalculatorIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @calculator = PopularityCalculator.new

    # for the sse test attempt
    # @port = 3000
    # @url = "http://localhost:#{@port}/popularity"
  end

  # def teardown
  #   @mock_server.stop
  # end


  test "should serve welcome page" do
    get "/"
    assert_select "h1", "Welcome to the shoe store dashboard!"
  end

  test "should process sales and calculate sales percentage correctly" do
    # arrange
    sales = [
      { "model" => "Model A", "store" => "Store A" },
      { "model" => "Model A", "store" => "Store B" },
      { "model" => "Model B", "store" => "Store C" },
      { "model" => "Model C", "store" => "Store D" }
    ]

    # act: process new sales & calculate popularity report
    sales.each do |sale|
      result = SalesProcessor.new.process_incoming_sale(sale)
      if !result[:success]
        puts "Sale processing failed: #{result[:errors]}"
      end
      assert result[:success]
    end
    result = @calculator.calculate

    # assert
    expected = [
      { model: "Model A", sales_percent: 50.0 },
      { model: "Model B", sales_percent: 25.0 },
      { model: "Model C", sales_percent: 25.0 }
    ]
    assert_equal expected, result
  end


  test "should process sales and ignore invalid data" do
    # arrange
    sales = [
      { "model" => "Model A", "store" => "Store A" },
      { "model" => "Model A", "store" => "Store B" },
      { "model" => "Model B", "store" => "" },
      { "model" => "Model C", "store" => nil },
      { "potato" => "potato" },
      { potato: "potato" }
    ]

    # act: process new sales & calculate popularity report
    sales.each do |sale|
      SalesProcessor.new.process_incoming_sale(sale)
    end
    result = @calculator.calculate

    # assert
    expected = [
      #  the only valid sales are for model A, nothing else should appear
      { model: "Model A", sales_percent: 100.0 }
    ]
    assert_equal expected, result
  end


  # Attempt to test business logic + websocket client, by making a mock websocket server
  # test "should receive sales events and calculate sales percentage correctly" do
  #   # arrange
  #   @mock_server = MockWebSocketServer.new(8080), todo: pass it some mock data to send
  #   Thread.new { @mock_server.run }
  #   sleep 2 # give the server time to start
  #   sleep 5 # wait for a few events to be received, todo: better way than sleep?
  #
  #   # act
  #   result = @calculator.calculate
  #
  #   # assert
  #   expected_report = [
  #     { model: "Model A", sales_percent: 100.0 } # todo: more test cases
  #   ]
  #   assert_equal expected_report, result
  # end

  # Attempt to test SSE events + business logic
  # test "should calculate popularity and send popularity report" do
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
  #   end
  #   sleep 10 # todo: don't sleep, disconnect after X messages instead
  #
  #   # assert ...
  #   assert true
  # end
end
