class AddGapResultsToGapUps < ActiveRecord::Migration
  def change
    add_column :gap_ups, :strategy_number, :integer
    add_column :gap_ups, :trade_outcome, :decimal
  end
end
