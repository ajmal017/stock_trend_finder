class SetDailyStockPriceDecimalPrecision < ActiveRecord::Migration
  def change
    change_column :daily_stock_prices, :open, :decimal, :precision=>15, :scale=>2
    change_column :daily_stock_prices, :high, :decimal, :precision=>15, :scale=>2
    change_column :daily_stock_prices, :low, :decimal, :precision=>15, :scale=>2
    change_column :daily_stock_prices, :close, :decimal, :precision=>15, :scale=>2
    change_column :daily_stock_prices, :previous_high, :decimal, :precision=>15, :scale=>2
    change_column :daily_stock_prices, :previous_low, :decimal, :precision=>15, :scale=>2
    change_column :daily_stock_prices, :previous_close, :decimal, :precision=>15, :scale=>2
    change_column :daily_stock_prices, :volume, :decimal, :precision=>15, :scale=>3
    change_column :daily_stock_prices, :average_volume_50day, :decimal, :precision=>15, :scale=>3
    change_column :daily_stock_prices, :sma50, :decimal, :precision=>15, :scale=>3
    change_column :daily_stock_prices, :sma200, :decimal, :precision=>15, :scale=>3
  end
end
