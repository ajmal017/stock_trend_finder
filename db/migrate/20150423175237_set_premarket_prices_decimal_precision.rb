class SetPremarketPricesDecimalPrecision < ActiveRecord::Migration
  def change
    change_column :premarket_prices, :last_trade, :decimal, :precision=>15, :scale=>2
    change_column :premarket_prices, :high, :decimal, :precision=>15, :scale=>2
    change_column :premarket_prices, :low, :decimal, :precision=>15, :scale=>2
    change_column :premarket_prices, :close, :decimal, :precision=>15, :scale=>2
    change_column :premarket_prices, :previous_high, :decimal, :precision=>15, :scale=>2
    change_column :premarket_prices, :previous_low, :decimal, :precision=>15, :scale=>2
    change_column :premarket_prices, :previous_close, :decimal, :precision=>15, :scale=>2
    change_column :premarket_prices, :volume, :decimal, :precision=>15, :scale=>3
    change_column :premarket_prices, :average_volume_50day, :decimal, :precision=>15, :scale=>3
  end
end
