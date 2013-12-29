class CreateDividends < ActiveRecord::Migration
  def change
    create_table :dividends do |t|
      t.integer :ticker_id
      t.date :issue_date
      t.decimal :amount

      t.timestamps
    end
    add_index :dividends, [:ticker_id, :issue_date], :unique => true
  end
end
