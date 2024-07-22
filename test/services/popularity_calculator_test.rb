require "test_helper"

class PopularityCalculatorTest < ActiveSupport::TestCase
  def setup
    @calculator = PopularityCalculator.new
  end

  test "should calculate sales percentage correctly" do
    # arrange
    # todo: is there a more idiomatic way? fixtures?
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

  # todo: move to integration
  # test "should ignore model with empty name" do
  #   # arrange
  #   Sale.create(model: "Model A", store: "Store A")
  #   Sale.create(model: "",  store: "Store B")

  #   # act & assert
  #   expected_report = [
  #     { model: "Model A", sales_percent: 100.0 }
  #   ]
  #   assert_equal expected_report, @calculator.calculate
  # end

  test "should return 100% if only one model sold" do
    # arrange
    Sale.create(model: "Model A", store: "Store A")
    Sale.create(model: "Model A",  store: "Store B")

    # act & assert
    expected_report = [
      { model: "Model A", sales_percent: 100.0 }
    ]
    assert_equal expected_report, @calculator.calculate
  end

  test "should return empty report when empty data" do
    # arrange: no sales data

    # act & assert
    expected_report = []
    assert_equal expected_report, @calculator.calculate
  end
end
