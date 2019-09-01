class AddDaysAbove52WkPer45ToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :days_above_52week_per_45_days, :integer
  end
end