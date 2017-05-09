class AddMovingAveragesToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :sma50, :decimal
    add_column :daily_stock_prices, :sma200, :decimal
  end
end
