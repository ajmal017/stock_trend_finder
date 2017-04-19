class CreateStocktwitWatchTickers < ActiveRecord::Migration
  def change
    create_table :stocktwit_watch_tickers do |t|
      t.string :ticker_symbol
      t.boolean :watching

      t.timestamps
    end

    add_index 'stocktwit_watch_tickers', :ticker_symbol, :unique=>true
  end
end
