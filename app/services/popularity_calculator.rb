class PopularityCalculator
  def initialize
  end

  def calculate
    model_sales = Sale.group(:model).count
    total_sales = model_sales.values.sum
    sales_percent = model_sales.transform_values do |count|
      (count.to_f / total_sales * 100).round(2) # todo: ...
    end

    generate_report(sales_percent)
  end

  private

  def generate_report(sales_percent)
    sales_percent.map do |model, percentage|
      { model: model, sales_percent: percentage } # todo: ...
    end
  end
end
