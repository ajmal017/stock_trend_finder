class DenormalizeTickerIdFromDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :ticker_symbol, :string
  end
end
