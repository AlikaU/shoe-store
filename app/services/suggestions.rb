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

  class PutOnSale < Suggestion
    def suggest
      worst_seller = sales_stats(:worst)
      "Discount idea: #{worst_seller[:model]} is falling behind with just #{worst_seller[:sales_percent]}% of total sales. Consider a discount to move inventory."
    end
  end

  class OrderMore < Suggestion
    def suggest
      best_seller = sales_stats(:best)
      "Top performer: #{best_seller[:model]} is the crowd favorite, making up #{best_seller[:sales_percent]}% of total sales. Keep up with customer demand by ordering more!"
    end
  end
end
