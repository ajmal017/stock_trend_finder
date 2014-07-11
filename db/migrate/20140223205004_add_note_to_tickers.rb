class AddNoteToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :note, :string
  end
end
