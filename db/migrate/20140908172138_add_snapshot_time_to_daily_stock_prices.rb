class AddSnapshotTimeToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :snapshot_time, :datetime
  end
end
