class AddHideFromReportsUntilToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :hide_from_reports_until, :date
  end
end
