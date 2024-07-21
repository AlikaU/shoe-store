# test/models/popularity_calculator_test.rb
require "test_helper"

class PopularityCalculatorTest < ActiveSupport::TestCase
  def setup
    @calculator = PopularityCalculator.new
  end

  test "should calculate sales percentage correctly" do
    # arrange
    Sale.create(model: "Model A", store: "Store A")
    Sale.create(model: "Model A",  store: "Store B")
    Sale.create(model: "Model B",  store: "Store C")
    Sale.create(model: "Model C",  store: "Store D")

    # act & assert
    expected_report = [
      { model: "Model A", sales_percent: 50.0 },
      { model: "Model B", sales_percent: 25.0 },
      { model: "Model C", sales_percent: 25.0 }
    ]
    assert_equal expected_report, @calculator.calculate
  end
end
