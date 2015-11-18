class CreateTickerNotes < ActiveRecord::Migration
  def change
    create_table :ticker_notes do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.date :note_date
      t.string :note_type
      t.text :note_text

      t.timestamps null: false
    end

    add_index :ticker_notes, :ticker_symbol
  end
end
