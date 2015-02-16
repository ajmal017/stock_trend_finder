class CreatePremarketPrices < ActiveRecord::Migration
  def change
    create_table :premarket_prices do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.date :price_date
      t.string :latest_print_time
      t.decimal :last_trade
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.decimal :volume
      t.decimal :average_volume

      t.timestamps
    end
  end
end
