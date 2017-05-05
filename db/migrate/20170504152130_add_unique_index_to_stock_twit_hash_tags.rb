class AddUniqueIndexToStockTwitHashTags < ActiveRecord::Migration
  def change
    add_index :stocktwit_hashtags, [:stocktwit_id, :tag], unique: true
  end
end
