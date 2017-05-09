class AddExcludeToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :exclude, :boolean, default: false
  end
end
