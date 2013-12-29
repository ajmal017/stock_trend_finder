class CreateStockSplits < ActiveRecord::Migration
  def change
    create_table :stock_splits do |t|
      t.integer :ticker_id
      t.date :split_date
      t.decimal :receive_shares
      t.decimal :for_every_shares
      t.timestamps
    end
  end
end
