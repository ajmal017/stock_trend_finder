class RenameAverageTrueRange120ToAverageTrueRange60 < ActiveRecord::Migration
  def change
    rename_column :stock_prices15_minutes, :average_true_range_120, :average_true_range_60
    rename_column :stock_prices5_minutes, :average_true_range_120, :average_true_range_60
  end
end
