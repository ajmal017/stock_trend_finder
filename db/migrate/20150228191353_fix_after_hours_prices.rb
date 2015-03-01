class FixAfterHoursPrices < ActiveRecord::Migration
  def change
    rename_column :after_hours_prices, :ah_high, :high
    rename_column :after_hours_prices, :ah_low, :low
    rename_column :after_hours_prices, :ah_volume, :volume
    remove_column :after_hours_prices, :ah_vwap
    add_column :after_hours_prices, :last_trade, :decimal
    add_column :after_hours_prices, :lastest_print_time, :datetime
    add_column :after_hours_prices, :intraday_high, :decimal
    add_column :after_hours_prices, :intraday_low, :decimal
    add_column :after_hours_prices, :intraday_close, :decimal
    add_column :after_hours_prices, :average_volume_50day, :decimal
  end
end
