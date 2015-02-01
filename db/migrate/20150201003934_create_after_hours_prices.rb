class CreateAfterHoursPrices < ActiveRecord::Migration
  def change
    create_table :after_hours_prices do |t|
      t.date :price_date
      t.string :ticker_symbol
      t.decimal :ah_high
      t.decimal :ah_low
      t.decimal :ah_volume
      t.decimal :ah_vwap

      t.timestamps
    end
  end
end
