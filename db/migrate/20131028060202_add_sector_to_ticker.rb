class AddSectorToTicker < ActiveRecord::Migration
  def change
    add_column :tickers, :sector, :string
  end
end
