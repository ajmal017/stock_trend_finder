class AddHigh52WeekStreakToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :high_52_week_streak, :integer
    add_column :daily_stock_prices, :low_52_week_streak, :integer
    remove_column :daily_stock_prices, :days_above_52week_per_45_days
  end
end
