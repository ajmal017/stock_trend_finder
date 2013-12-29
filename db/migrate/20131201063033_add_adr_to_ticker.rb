class AddAdrToTicker < ActiveRecord::Migration
  def change
    add_column :tickers, :adr, :boolean
  end
end
