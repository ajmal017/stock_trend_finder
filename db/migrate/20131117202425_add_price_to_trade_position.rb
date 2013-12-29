class AddPriceToTradePosition < ActiveRecord::Migration
  def change
    add_column :trade_positions, :price, :decimal
  end
end
