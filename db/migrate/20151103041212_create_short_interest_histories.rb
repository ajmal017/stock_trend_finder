class CreateShortInterestHistories < ActiveRecord::Migration
  def change
    create_table :short_interest_histories do |t|
      t.string :ticker_symbol
      t.date :as_of_date
      t.integer :shares_short
      t.decimal :shares_short_pct_float,   precision: 15, scale: 3
      t.decimal :short_ratio, precision: 15, scale: 3

      t.timestamps null: false
    end
  end
end
