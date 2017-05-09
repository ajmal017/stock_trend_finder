class AddTickerIdToDailyStockPrices < ActiveRecord::Migration
  def change
    rename_column :daily_stock_prices, :ticker, :ticker_id
  end
end
