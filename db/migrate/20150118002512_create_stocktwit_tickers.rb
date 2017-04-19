class CreateStocktwitTickers < ActiveRecord::Migration
  def change
    create_table :stocktwit_tickers do |t|
      t.integer :stocktwit_id
      t.string :ticker_symbol

      t.timestamps
    end
    add_index "stocktwit_tickers", [:ticker_symbol], name: "index_ticker_symbols_on_stocktwit_tickers", using: :btree
  end
end
