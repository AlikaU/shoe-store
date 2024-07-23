# This class holds the business logic for processing the incoming sales.
# For now, the logic is trivial, but in the future it could be creating entries in additional db tables
# or perform some calculations.

class SalesProcessor
  def initialize
  end

  def process_incoming_sale(sale_data)
    #       # todo: add more tables for other features as needed, e.g. inventory
    #       # note: could insert in batches if hitting the db too often is a concern
    sale = Sale.new(model: sale_data["model"], store: sale_data["store"])
    if sale.save
      puts "New sale processed: #{sale_data}"
      { success: true }
    else
      { success: false, errors: sale.errors.full_messages }
    end
  end
end
