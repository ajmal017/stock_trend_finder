class AddDateRemovedToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :date_removed, :datetime
  end
end
