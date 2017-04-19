class CreateStocktwits < ActiveRecord::Migration
  def change
    create_table :stocktwits do |t|
      t.integer :stocktwit_id
      t.datetime :stocktwit_time
      t.string :stocktwit_url
      t.string :symbol
      t.string :message
      t.string :image_thumb_url
      t.string :image_large_url
      t.string :image_original_url
      t.boolean :hide

      t.timestamps
    end
  end
end
