class AddNoteToStockTwits < ActiveRecord::Migration
  def change
    add_column :stocktwits, :note, :string
  end
end
