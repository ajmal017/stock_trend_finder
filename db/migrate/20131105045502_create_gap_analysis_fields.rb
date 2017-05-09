class CreateGapAnalysisFields < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices,  :days_since_previous_trading_day, :integer
    add_column :daily_stock_prices,  :open_higher_than_previous_day_high, :boolean
    add_column :daily_stock_prices,  :low_higher_than_previous_day_high, :boolean
    add_column :daily_stock_prices,  :day_gap, :boolean
    add_column :daily_stock_prices,  :close_higher_than_low, :boolean
    add_column :daily_stock_prices,  :low_pct_of_previous_day_high, :boolean
  end
end
