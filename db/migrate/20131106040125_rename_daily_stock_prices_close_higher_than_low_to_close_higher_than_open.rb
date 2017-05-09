class RenameDailyStockPricesCloseHigherThanLowToCloseHigherThanOpen < ActiveRecord::Migration
  def change
    rename_column :daily_stock_prices, :close_higher_than_low, :close_higher_than_open
  end
end
