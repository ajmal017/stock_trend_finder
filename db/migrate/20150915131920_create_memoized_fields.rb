class CreateMemoizedFields < ActiveRecord::Migration
  def change
    create_table :memoized_fields do |t|
      t.string :ticker_symbol
      t.date :price_date
      t.decimal :premarket_average_volume_50day, precision: 15, scale: 2
      t.decimal :premarket_previous_high, precision: 15, scale: 2
      t.decimal :premarket_previous_low, precision: 15, scale: 2
      t.decimal :premarket_previous_close, precision: 15, scale: 2

      t.timestamps
    end
  end
end
