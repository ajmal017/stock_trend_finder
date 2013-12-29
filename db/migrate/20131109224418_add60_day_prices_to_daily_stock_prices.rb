class Add60DayPricesToDailyStockPrices < ActiveRecord::Migration
  def change
    add_column :daily_stock_prices, :"close_60day", :decimal
    add_column :daily_stock_prices, :"high_60day", :decimal
    add_column :daily_stock_prices, :"low_60day", :decimal
    add_column :daily_stock_prices, :"high_5day_date", :date
    add_column :daily_stock_prices, :"low_5day_date", :date
    add_column :daily_stock_prices, :"high_10day_date", :date
    add_column :daily_stock_prices, :"low_10day_date", :date
    add_column :daily_stock_prices, :"high_30day_date", :date
    add_column :daily_stock_prices, :"low_30day_date", :date
    add_column :daily_stock_prices, :"high_60day_date", :date
    add_column :daily_stock_prices, :"low_60day_date", :date
  end
end
