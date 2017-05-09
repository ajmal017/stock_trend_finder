class CreateRealTimeQuotes < ActiveRecord::Migration
  def change
    create_table :real_time_quotes do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.decimal :price
      t.datetime :quote_time

      t.timestamps
    end
  end
end
