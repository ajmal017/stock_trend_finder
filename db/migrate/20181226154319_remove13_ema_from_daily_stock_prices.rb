class Remove13EmaFromDailyStockPrices < ActiveRecord::Migration
  def change
    remove_column :daily_stock_prices, :exclude
    remove_column :daily_stock_prices, :ema13
    remove_column :daily_stock_prices, :candle_vs_ema13
  end
end
