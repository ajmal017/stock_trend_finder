class CreateStockPrices15minutes < ActiveRecord::Migration
  def change
    create_table :stock_prices15_minutes do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.datetime :price_time
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.decimal :volume
      t.decimal :true_range
      t.decimal :true_range_percent
      t.decimal :average_true_range_120

      t.timestamps
    end

    add_index "stock_prices15_minutes", ["price_time"], name: "index_stock_prices15_minutes_on_price_time", using: :btree
    add_index "stock_prices15_minutes", ["ticker_symbol"], name: "index_stock_prices15_minutes_on_ticker_symbol", using: :btree
  end
end
