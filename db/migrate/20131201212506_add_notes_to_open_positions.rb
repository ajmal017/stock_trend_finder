class AddNotesToOpenPositions < ActiveRecord::Migration
  def change
    add_column :open_positions, :notes, :text
  end
end
