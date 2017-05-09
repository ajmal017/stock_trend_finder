class AddClosePriceToGapUpSimulationTrades < ActiveRecord::Migration
  def change
    add_column :gap_up_simulation_trades, :trade_open, :decimal
    add_column :gap_up_simulation_trades, :trade_close, :decimal
  end
end
