class AddTickerIdToTradePositions < ActiveRecord::Migration
  def change
    add_column :trade_positions, :ticker_id, :integer
  end
end
