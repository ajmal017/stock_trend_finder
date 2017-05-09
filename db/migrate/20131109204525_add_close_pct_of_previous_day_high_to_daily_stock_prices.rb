class AddClosePctOfPreviousDayHighToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :close_pct_of_previous_day_high, :decimal
  end
end
