class AddConstraintsToMinuteStockPrices < ActiveRecord::Migration
  def change
    add_index "minute_stock_prices", ["price_time"], name: "index_minute_stock_prices_on_price_time", using: :btree
    add_index "minute_stock_prices", ["ticker_id", "price_time"], name: "index_minute_stock_prices_on_ticker_id_and_price_time", unique: true, using: :btree
    add_index "minute_stock_prices", ["ticker_symbol"], name: "index_minute_stock_prices_on_ticker_symbol", using: :btree
  end
end
