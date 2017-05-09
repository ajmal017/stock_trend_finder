class AddRangePctToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :range_pct, :decimal
  end
end
