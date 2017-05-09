class CreateDailyStockPrices < ActiveRecord::Migration
  def change
    create_table :daily_stock_prices do |t|
      t.integer :ticker
      t.date :price_date
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.integer :volume
      t.decimal :yahoo_adj_close
      t.decimal :adj_close

      t.timestamps
    end
  end
end
