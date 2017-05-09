class CreateTradePositions < ActiveRecord::Migration
  def change
    create_table :trade_positions do |t|
      t.integer :gap_up_id
      t.date :trade_date
      t.string :position
      t.decimal :value

      t.timestamps
    end
  end
end
