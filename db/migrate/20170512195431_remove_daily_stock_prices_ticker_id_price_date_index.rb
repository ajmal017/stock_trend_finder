class RemoveDailyStockPricesTickerIdPriceDateIndex < ActiveRecord::Migration
  def change
    remove_index :daily_stock_prices, [:ticker_id, :price_date]
  end
end
