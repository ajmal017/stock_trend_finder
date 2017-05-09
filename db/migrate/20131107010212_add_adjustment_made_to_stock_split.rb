class AddAdjustmentMadeToStockSplit < ActiveRecord::Migration
  def change
    add_column :stock_splits, :adjustment_made, :boolean
  end
end
