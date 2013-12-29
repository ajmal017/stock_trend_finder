class AddGapUpIdIndexToTradePosition < ActiveRecord::Migration
  def change
    add_index :trade_positions, [:gap_up_id, :position]
  end
end
