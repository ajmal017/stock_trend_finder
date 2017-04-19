class SetAfterhoursDecimalPrecision < ActiveRecord::Migration
  def change
    change_column :after_hours_prices, :last_trade, :decimal, :precision=>15, :scale=>2
    change_column :after_hours_prices, :high, :decimal, :precision=>15, :scale=>2
    change_column :after_hours_prices, :low, :decimal, :precision=>15, :scale=>2
    change_column :after_hours_prices, :intraday_high, :decimal, :precision=>15, :scale=>2
    change_column :after_hours_prices, :intraday_low, :decimal, :precision=>15, :scale=>2
    change_column :after_hours_prices, :intraday_close, :decimal, :precision=>15, :scale=>2
    change_column :after_hours_prices, :volume, :decimal, :precision=>15, :scale=>3
    change_column :after_hours_prices, :average_volume_50day, :decimal, :precision=>15, :scale=>3
  end
end
