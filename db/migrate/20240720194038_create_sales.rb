class CreateSales < ActiveRecord::Migration[7.2]
  def change
    create_table :sales do |t|
      t.string :model
      t.string :store

      t.timestamps
    end
  end
end
