class CreateStockTrades < ActiveRecord::Migration
  def change
    create_table :stock_trades do |t|
      t.integer :price_gap_id
      t.string :action
      t.decimal :pct_value_end

      t.timestamps
    end
  end
end
