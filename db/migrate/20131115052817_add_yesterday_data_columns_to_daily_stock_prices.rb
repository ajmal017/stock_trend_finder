class AddYesterdayDataColumnsToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :previous_trading_day, :date
    add_column :daily_stock_prices, :previous_close, :decimal
    add_column :daily_stock_prices, :previous_high, :decimal
    add_column :daily_stock_prices, :previous_low, :decimal
  end
end
