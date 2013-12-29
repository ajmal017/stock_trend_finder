class CreateTickers < ActiveRecord::Migration
  def change
    create_table :tickers do |t|
      t.string :symbol
      t.string :company_name
      t.string :exchange

      t.timestamps
    end
  end
end
