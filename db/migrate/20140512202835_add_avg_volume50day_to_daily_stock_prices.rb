class AddAvgVolume50dayToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :average_volume_50day, :decimal
  end
end
