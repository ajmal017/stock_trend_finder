class AddEma13ToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :ema13, :decimal
  end
end
