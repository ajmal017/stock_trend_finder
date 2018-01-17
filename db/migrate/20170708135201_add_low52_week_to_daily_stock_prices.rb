class AddLow52WeekToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :low_52_week, :float
  end
end
