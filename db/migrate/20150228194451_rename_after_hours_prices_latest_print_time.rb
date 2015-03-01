class RenameAfterHoursPricesLatestPrintTime < ActiveRecord::Migration
  def change
    rename_column :after_hours_prices, :lastest_print_time, :latest_print_time
  end
end
