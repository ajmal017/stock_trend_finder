class CreateGapUps < ActiveRecord::Migration
  def change
    create_table :gap_ups do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.date :price_date
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.decimal :previous_close
      t.decimal :previous_high
      t.decimal :previous_low
      t.decimal :open_pct_of_previous_high

      t.timestamps
    end
  end
end
