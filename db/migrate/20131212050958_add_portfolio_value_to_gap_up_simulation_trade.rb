class AddPortfolioValueToGapUpSimulationTrade < ActiveRecord::Migration
  def change
    add_column :gap_up_simulation_trades, :portfolio_value, :decimal
    add_column :gap_up_simulation_trades, :cash, :decimal
    add_column :gap_up_simulation_trades, :invested_value, :decimal
  end
end
