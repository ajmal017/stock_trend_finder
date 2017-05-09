class AddWatchingToStocktwits < ActiveRecord::Migration
  def change
    add_column :stocktwits, :watching, :boolean
  end
end
