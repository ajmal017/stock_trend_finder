class AddTickerSymbolIndexToPremarketPrices < ActiveRecord::Migration
  def change
    add_index "premarket_prices", ["ticker_symbol", "price_date"], name: "index_premarket_prices_on_ticker_symbol_and_price_date", unique: true, using: :btree
  end
end
