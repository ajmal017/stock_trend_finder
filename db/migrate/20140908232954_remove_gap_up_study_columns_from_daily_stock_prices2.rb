class RemoveGapUpStudyColumnsFromDailyStockPrices2 < ActiveRecord::Migration
  def change
    remove_column :daily_stock_prices, :high_10day_date
    remove_column :daily_stock_prices, :low_10day_date

  end
end
