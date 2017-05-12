class AddUniqueIndexToTickersSymbol < ActiveRecord::Migration
  def change
    remove_index :tickers, :symbol
    add_index :tickers, [:symbol], unique: true
  end
end
