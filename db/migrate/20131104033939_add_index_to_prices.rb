class AddIndexToPrices < ActiveRecord::Migration
  def change
    add_index :daily_stock_prices, [:ticker_id, :price_date], :unique => true
  end
end
