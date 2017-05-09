class AddWatchToTicker < ActiveRecord::Migration
  def change
    add_column :tickers, :watch, :boolean
  end
end
