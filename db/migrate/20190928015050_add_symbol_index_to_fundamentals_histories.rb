class AddSymbolIndexToFundamentalsHistories < ActiveRecord::Migration
  def change
    add_index "fundamentals_histories", ["ticker_symbol", "scrape_date"], name: "index_fh_symbol_scrape_date", using: :btree
    add_index "fundamentals_histories", ["scrape_date", "ticker_symbol"], name: "index_fh_scrape_date_symbol", using: :btree
  end
end
