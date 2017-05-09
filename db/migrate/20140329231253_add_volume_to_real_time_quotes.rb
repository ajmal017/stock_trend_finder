class AddVolumeToRealTimeQuotes < ActiveRecord::Migration
  def change
    add_column :real_time_quotes, :volume, :decimal, precision: 15, scale: 0
  end
end
