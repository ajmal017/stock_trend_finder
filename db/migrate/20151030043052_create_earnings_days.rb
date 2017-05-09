class CreateEarningsDays < ActiveRecord::Migration
  def change
    create_table :earnings_days do |t|
      t.date :earnings_date
      t.boolean :before_the_open
      t.string :tickers

      t.timestamps null: false
    end
  end
end
