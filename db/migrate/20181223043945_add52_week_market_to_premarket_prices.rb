class Add52WeekMarketToPremarketPrices < ActiveRecord::Migration
  def up
    add_column :premarket_prices, :high_52_week, :float
    add_column :premarket_prices, :low_52_week, :float
  end

  def down
    remove_column :premarket_prices, :high_52_week, :float
    remove_column :premarket_prices, :low_52_week, :float
  end
end
