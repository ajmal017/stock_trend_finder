class RemoveStockTwitWatching < ActiveRecord::Migration
  def change
    remove_column :stocktwits, :watching
  end
end
