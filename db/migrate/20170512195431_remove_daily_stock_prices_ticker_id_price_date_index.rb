class RemoveDailyStockPricesTickerIdPriceDateIndex < ActiveRecord::Migration
  def change
    #remove_index :daily_stock_prices, [:ticker_id, :price_date] # don't need to remove this on production it was never there
  end
end
