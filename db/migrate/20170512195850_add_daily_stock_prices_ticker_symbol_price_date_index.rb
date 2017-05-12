class AddDailyStockPricesTickerSymbolPriceDateIndex < ActiveRecord::Migration
  def change
    add_index :daily_stock_prices, [:ticker_symbol, :price_date], unique: true
  end
end
