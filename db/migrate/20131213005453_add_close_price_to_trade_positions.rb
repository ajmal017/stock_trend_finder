class AddClosePriceToTradePositions < ActiveRecord::Migration
  def change
    add_column :trade_positions, :close_price, :decimal
  end
end
