class RemoveGapUpStudyColumnsFromDailyStockPrices < ActiveRecord::Migration
  def change
    remove_column :daily_stock_prices, :yahoo_adj_close
    remove_column :daily_stock_prices, :adj_close
    remove_column :daily_stock_prices, :days_since_previous_trading_day
    remove_column :daily_stock_prices, :open_higher_than_previous_day_high
    remove_column :daily_stock_prices, :low_higher_than_previous_day_high
    remove_column :daily_stock_prices, :day_gap
    remove_column :daily_stock_prices, :close_higher_than_open
    remove_column :daily_stock_prices, :low_pct_of_previous_day_high
    remove_column :daily_stock_prices, :close_5day
    remove_column :daily_stock_prices, :high_5day
    remove_column :daily_stock_prices, :low_5day
    remove_column :daily_stock_prices, :close_10day
    remove_column :daily_stock_prices, :high_10day
    remove_column :daily_stock_prices, :low_10day
    remove_column :daily_stock_prices, :close_30day
    remove_column :daily_stock_prices, :high_30day
    remove_column :daily_stock_prices, :low_30day
    remove_column :daily_stock_prices, :close_pct_of_previous_day_high
    remove_column :daily_stock_prices, :close_60day
    remove_column :daily_stock_prices, :high_60day
    remove_column :daily_stock_prices, :low_60day
    remove_column :daily_stock_prices, :high_5day_date
    remove_column :daily_stock_prices, :low_5day_date
    remove_column :daily_stock_prices, :high_30day_date
    remove_column :daily_stock_prices, :low_30day_date
    remove_column :daily_stock_prices, :high_60day_date
    remove_column :daily_stock_prices, :low_60day_date
    remove_column :daily_stock_prices, :previous_trading_day
    remove_column :daily_stock_prices, :range_pct
  end
end
