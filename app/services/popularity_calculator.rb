# This class calculates the popularity of each model based on the number of sales.
# We assume that each event coming from the provided program represents 1 sale,
# and also assume that 1 sale means 1 pair of shoes sold.
# It returns a report with the percentage of total sales for each model.
class PopularityCalculator
  def initialize
  end

  def calculate
    model_sales = Sale.group(:model).count # keys: model names, values: sales count
    total_sales = model_sales.values.sum
    sales_percent = model_sales.transform_values do |count|
      (count.to_f / total_sales * 100).round(2)
    end

    generate_report(sales_percent)
  end

  private

  # return an array of hashes with model and sales_percent keys, ready to be returned as json
  def generate_report(sales_percent)
    sales_percent.map do |model, percentage|
      { model: model, sales_percent: percentage }
    end
  end
end
