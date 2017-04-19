class AddTickerSymbolIndexToDailyStockPrices < ActiveRecord::Migration
  def change
    add_index :daily_stock_prices, :ticker_symbol
  end
end
