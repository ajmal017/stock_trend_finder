class AddCloseToTradePositions < ActiveRecord::Migration
  def change
    add_column :trade_positions, :close_date, :date
    add_column :trade_positions, :close_value, :decimal
  end
end
