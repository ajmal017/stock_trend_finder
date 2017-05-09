class CreatePriceGaps < ActiveRecord::Migration
  def change
    create_table :price_gaps do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.date :price_date
      t.decimal :previous_day_close
      t.decimal :previous_day_high
      t.decimal :today_open
      t.boolean :participate

      t.timestamps
    end
  end
end
