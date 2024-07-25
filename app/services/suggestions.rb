# This class is responsible for generating suggestions based on sales data.
# It randomly selects a suggestion type and generates a suggestion message.
class Suggestions
  def initialize
    @suggestions = [ PutOnSale, OrderMore ]
  end

  def make_suggestion
    @suggestions.sample.new.suggest
  end

  class Suggestion
    def suggest
      raise NotImplementedError("Override me")
    end

    protected

    def sales_stats(type)
      model_sales = Sale.group(:model).count
      total_sales = model_sales.values.sum
      case type
      when :best
        model, count = model_sales.max_by { |model, count| count }
      when :worst
        model, count = model_sales.min_by { |model, count| count }
      end
      sales_percent = (count.to_f / total_sales * 100).round(2)
      {
        model: model,
        sales_percent: sales_percent
      }
    end
  end

  # Suggest putting the worst selling model on sale
  class PutOnSale < Suggestion
    def suggest
      worst_seller = sales_stats(:worst)
      "#{worst_seller[:model]} is falling behind with only #{worst_seller[:sales_percent]}% of total sales. Consider putting it on discount."
    end
  end

  # Suggest ordering more of the best selling model
  class OrderMore < Suggestion
    def suggest
      best_seller = sales_stats(:best)
      "#{best_seller[:model]} is selling really well, making up #{best_seller[:sales_percent]}% of total sales. We should order some more!"
    end
  end
end
