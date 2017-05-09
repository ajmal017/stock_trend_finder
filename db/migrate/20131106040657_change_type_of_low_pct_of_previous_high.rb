class ChangeTypeOfLowPctOfPreviousHigh < ActiveRecord::Migration
  def change
    remove_column :daily_stock_prices, :low_pct_of_previous_day_high
    add_column :daily_stock_prices, :low_pct_of_previous_day_high, :decimal
  end
end
