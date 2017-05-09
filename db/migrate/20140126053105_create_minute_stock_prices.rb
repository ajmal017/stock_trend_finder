class CreateMinuteStockPrices < ActiveRecord::Migration
  def change
    create_table :minute_stock_prices do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.datetime :price_time
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.decimal :volume, precision: 15, scale: 0

      t.timestamps
    end
  end
end
