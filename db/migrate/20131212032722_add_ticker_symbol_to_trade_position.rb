class AddTickerSymbolToTradePosition < ActiveRecord::Migration
  def change
    add_column :trade_positions, :ticker_symbol, :string
  end
end
