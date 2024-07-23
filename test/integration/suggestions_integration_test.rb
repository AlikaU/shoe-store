require "test_helper"
require "mocha/minitest"

class SuggestionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    Sale.delete_all
    sales = [
      { "model" => "Model A", "store" => "Store A" }, # Model A is sold the least
      { "model" => "Model B", "store" => "Store A" }, # Model B is the bestseller
      { "model" => "Model B", "store" => "Store A" },
      { "model" => "Model B", "store" => "Store A" },
      { "model" => "Model C", "store" => "Store A" },
      { "model" => "Model C", "store" => "Store A" }
    ]
    sales.each do |sale|
      SalesProcessor.new.process_incoming_sale(sale)
    end
  end

  test "should return suggestion" do
    # arrange: nothing to do
    # act
    get suggestions_url

    # assert
    assert_response :success
    assert JSON.parse(response.body)["suggestion"].include?("% of total sales")
  end

  test "should return correct PutOnSale suggestion" do
    # arrange
    # make Suggestions return a PutOnSale suggestion
    Suggestions.any_instance.stubs(:make_suggestion).returns(Suggestions::PutOnSale.new.suggest)

    # act
    get suggestions_url

    # assert
    assert_response :success
    expected = "Discount idea: Model A is falling behind with just (0.17% of total sales). Consider a discount to move inventory."
    assert_equal expected, JSON.parse(response.body)["suggestion"]
  end

  test "should return a correct OrderMore suggestion" do
    # arrange
    # make Suggestions return an OrderMore suggestion
    Suggestions.any_instance.stubs(:make_suggestion).returns(Suggestions::OrderMore.new.suggest)

    # act
    get suggestions_url

    # assert
    assert_response :success
    expected = "Top performer: Model B is the crowd favorite, making up 0.5% of total sales. Keep up with customer demand by ordering more!"
    assert_equal expected, JSON.parse(response.body)["suggestion"]
  end
end
