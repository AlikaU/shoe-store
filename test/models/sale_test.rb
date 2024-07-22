require "test_helper"

class SaleTest < ActiveSupport::TestCase
  test "valid if model and store are present and nonempty" do
    sale = Sale.new(model: "Model A", store: "Store A")
    sale.valid?
    assert_empty sale.errors[:model]
  end

  test "invalid if model is nil" do
    sale = Sale.new(model: nil, store: "Store A")
    sale.valid?
    assert_not sale.errors[:model].empty?
  end

  test "invalid if model is empty" do
    sale = Sale.new(model: "", store: "Store A")
    sale.valid?
    assert_not sale.errors[:model].empty?
  end

  test "invalid if store is nil" do
    sale = Sale.new(model: "Model A", store: nil)
    sale.valid?
    assert_not sale.errors[:store].empty?
  end

  test "invalid if store is empty" do
    sale = Sale.new(model: "Model A", store: "")
    sale.valid?
    assert_not sale.errors[:store].empty?
  end
end
