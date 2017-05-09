class RemoveTradePositions < ActiveRecord::Migration
  def change
    drop_table :trade_positions
    drop_table :gap_ups
    drop_table :gap_up_simulation_trades
  end
end
