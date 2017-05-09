class RenamePremarketPricesAverageVolumeToAverageVolume50Day < ActiveRecord::Migration
  def change
    rename_column :premarket_prices, :average_volume, :average_volume_50day
  end
end
