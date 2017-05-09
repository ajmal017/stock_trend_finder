class CreateInstitutionalOwnershipSnapshots < ActiveRecord::Migration
  def change
    create_table :institutional_ownership_snapshots do |t|
      t.string :ticker_symbol
      t.date :scrape_date
      t.float :institutional_ownership_pct
      t.bigint :total_shares
      t.bigint :holdings_value
      t.integer :increased_positions_count
      t.integer :decreased_positions_count
      t.integer :held_positions_count
      t.bigint :increased_positions_shares
      t.bigint :decreased_positions_shares
      t.bigint :held_positions_shares
      t.integer :new_positions_count
      t.integer :sold_positions_count
      t.bigint :new_positions_shares
      t.bigint :sold_positions_shares

      t.timestamps null: false
    end
  end
end
