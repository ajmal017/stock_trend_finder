class CreateStocktwitHashtags < ActiveRecord::Migration
  def change
    create_table :stocktwit_hashtags do |t|
      t.integer :stocktwit_id
      t.string :tag

      t.timestamps
    end
  end
end
