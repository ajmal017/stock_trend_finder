class AdjustColumnsOnDailyPriceXDays < ActiveRecord::Migration
  def change
    remove_column :daily_stock_prices, :"5day_price", :decimal
    remove_column :daily_stock_prices, :"5day_high", :decimal
    remove_column :daily_stock_prices, :"5day_low", :decimal
    remove_column :daily_stock_prices, :"10day_high", :decimal
    remove_column :daily_stock_prices, :"10day_low", :decimal
    remove_column :daily_stock_prices, :"30day_price", :decimal
    remove_column :daily_stock_prices, :"30day_high", :decimal
    remove_column :daily_stock_prices, :"30day_low", :decimal
    remove_column :daily_stock_prices, :daily_stock_price_id, :integer
    add_column :daily_stock_prices, :"close_5day", :decimal
    add_column :daily_stock_prices, :"high_5day", :decimal
    add_column :daily_stock_prices, :"low_5day", :decimal
    add_column :daily_stock_prices, :"close_10day", :decimal
    add_column :daily_stock_prices, :"high_10day", :decimal
    add_column :daily_stock_prices, :"low_10day", :decimal
    add_column :daily_stock_prices, :"close_30day", :decimal
    add_column :daily_stock_prices, :"high_30day", :decimal
    add_column :daily_stock_prices, :"low_30day", :decimal
  end
end
