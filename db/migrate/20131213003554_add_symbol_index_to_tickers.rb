class AddSymbolIndexToTickers < ActiveRecord::Migration
  def change
    add_index :tickers, :symbol
  end
end
