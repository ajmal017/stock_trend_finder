class CreatePriceDates < ActiveRecord::Migration
  def change
    create_table :price_dates do |t|
      t.date :price_date
      t.integer :week

      t.timestamps
    end
  end
end
