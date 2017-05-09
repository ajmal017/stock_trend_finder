class AddIndexToAfterHoursPrices < ActiveRecord::Migration
  def change
    add_index "after_hours_prices", ["ticker_symbol", "price_date"], name: "index_after_hours_prices_on_ticker_symbol_and_price_date", unique: true, using: :btree

  end
end
