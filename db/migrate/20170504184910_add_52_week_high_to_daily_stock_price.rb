class Add52WeekHighToDailyStockPrice < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :high_52_week, :float, precision: 15, scale: 2
  end
end
