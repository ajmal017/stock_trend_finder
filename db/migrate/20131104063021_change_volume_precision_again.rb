class ChangeVolumePrecisionAgain < ActiveRecord::Migration
  def change
    change_column :daily_stock_prices, :volume, :decimal, :precision=>15
  end
end
