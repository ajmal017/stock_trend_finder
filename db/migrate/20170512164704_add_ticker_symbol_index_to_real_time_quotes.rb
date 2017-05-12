class AddTickerSymbolIndexToRealTimeQuotes < ActiveRecord::Migration
  def change
    add_index :real_time_quotes, [:ticker_symbol], name: 'index_real_time_quotes_ticker_symbol'
  end
end
