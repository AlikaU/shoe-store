require "test_helper"
require "mocha/minitest"

class SuggestionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    Sale.delete_all
    Sale.create(model: "Model A", store: "Store A") # Model A is sold the least
    Sale.create(model: "Model B", store: "Store A") # Model B is the bestseller
    Sale.create(model: "Model B", store: "Store A")
    Sale.create(model: "Model B", store: "Store A")
    Sale.create(model: "Model C", store: "Store A")
    Sale.create(model: "Model C", store: "Store A")
  end

  test "should return suggestion" do
    # arrange: nothing to do

    # act
    get suggestions_url

    # assert
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["suggestion"].include?("% of total sales")
  end

  test "should return correct PutOnSale suggestion" do
    # arrange
    # make Suggestions return a putonsale suggestion
    Suggestions.any_instance.stubs(:make_suggestion).returns(Suggestions::PutOnSale.new.suggest)

    # act
    get suggestions_url

    # assert
    assert_response :success
    json_response = JSON.parse(response.body)
    expected = "Discount idea: Model A is falling behind with just (0.17% of total sales). Consider a discount to move inventory."
    assert_equal expected, json_response["suggestion"]
  end

  test "should return a correct OrderMore suggestion" do
    # arrange
    # make Suggestions return an ordermore suggestion
    Suggestions.any_instance.stubs(:make_suggestion).returns(Suggestions::OrderMore.new.suggest)

    # act
    get suggestions_url

    # assert
    assert_response :success
    json_response = JSON.parse(response.body)
    expected = "Top performer: Model B is the crowd favorite, making up 0.5% of total sales. Keep up with customer demand by ordering more!"
    assert_equal expected, json_response["suggestion"]
  end
end
