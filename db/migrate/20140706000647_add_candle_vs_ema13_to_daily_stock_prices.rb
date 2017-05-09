class AddCandleVsEma13ToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :candle_vs_ema13, :string
  end
end
