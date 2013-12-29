class CreatePriceDateIndexOnDailyStockPrices < ActiveRecord::Migration
  def change
    add_index :daily_stock_prices, :price_date
  end
end
