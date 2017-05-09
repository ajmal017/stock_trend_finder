class AddNoteToTicker < ActiveRecord::Migration
  def change
    add_column :tickers, :gap_up_note, :string
  end
end
