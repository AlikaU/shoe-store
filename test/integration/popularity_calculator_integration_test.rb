require "test_helper"
require "faye/websocket"
require "helpers/mock_websocket_server"
require "em-eventsource"

# The tests in this file cover:
# - processing incoming sales data
# - db interaction
# - handling invalid data
# - calculating sales percentage
# - serving the popularity report
# todo: can we get a 500 response? add a test for it
class PopularityCalculatorIntegrationTest < ActionDispatch::IntegrationTest
  # for the websocket test attempt
  # def teardown
  #   @mock_server.stop
  # end

  test "should process sales and calculate sales percentage correctly" do
    # arrange
    sales = [
      { "model" => "Model A", "store" => "Store A" },
      { "model" => "Model A", "store" => "Store B" },
      { "model" => "Model B", "store" => "Store C" },
      { "model" => "Model C", "store" => "Store D" }
    ]

    # act: process new sales & get popularity report
    sales.each do |sale|
      result = SalesProcessor.new.process_incoming_sale(sale)
      if !result[:success]
        puts "Sale processing failed: #{result[:errors]}"
      end
      assert result[:success]
    end
    get "/popularity"

    # assert
    assert_response :success
    expected = [
      { "model" => "Model A", "sales_percent" => 50.0 },
      { "model" => "Model B", "sales_percent" => 25.0 },
      { "model" => "Model C", "sales_percent" => 25.0 }
  ]
    assert_equal expected, JSON.parse(response.body)
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
    get "/popularity"

    # assert
    assert_response :success
    expected = [
      #  the only valid sales are for model A, nothing else should appear
      { "model" => "Model A", "sales_percent" => 100.0 }
    ]
    assert_equal expected, JSON.parse(response.body)
  end


  # Attempt to cover the websocket client, by making a mock websocket server, did not manage to get it working
  #
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

  test "should serve welcome page" do
    get "/"
    assert_select "h1", "Welcome to the shoe store dashboard!"
  end
end
