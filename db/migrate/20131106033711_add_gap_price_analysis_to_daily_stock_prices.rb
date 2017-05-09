class AddGapPriceAnalysisToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :daily_stock_price_id, :integer
    add_column :daily_stock_prices, :"5day_price", :decimal
    add_column :daily_stock_prices, :"5day_high", :decimal
    add_column :daily_stock_prices, :"5day_low", :decimal
    add_column :daily_stock_prices, :"10day_high", :decimal
    add_column :daily_stock_prices, :"10day_low", :decimal
    add_column :daily_stock_prices, :"30day_price", :decimal
    add_column :daily_stock_prices, :"30day_high", :decimal
    add_column :daily_stock_prices, :"30day_low", :decimal
  end
end
