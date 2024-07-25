require "test_helper"

class SuggestionsTest < ActiveSupport::TestCase
  def setup
    Sale.delete_all
    Sale.create(model: "Model A", store: "Store A") # Model A is sold the least
    Sale.create(model: "Model B", store: "Store A") # Model B is the bestseller
    Sale.create(model: "Model B", store: "Store A")
    Sale.create(model: "Model B", store: "Store A")
    Sale.create(model: "Model C", store: "Store A")
    Sale.create(model: "Model C", store: "Store A")
  end

  test "make_suggestion returns a valid suggestion" do
    suggestions = Suggestions.new
    suggestion = suggestions.make_suggestion
    assert suggestion.include?("% of total sales")
  end

  test "PutOnSale returns correct suggestion" do
    put_on_sale = Suggestions::PutOnSale.new
    suggestion = put_on_sale.suggest
    expected = "Model A is falling behind with only 16.67% of total sales. Consider putting it on discount."
    assert_equal expected, suggestion
  end

  test "OrderMore returns correct suggestion" do
    order_more = Suggestions::OrderMore.new
    suggestion = order_more.suggest
    expected = "Model B is selling really well, making up 50.0% of total sales. We should order some more!"
    assert_equal expected, suggestion
  end
end
