class CreateLowLiquidityQuarters < ActiveRecord::Migration
  def change
    create_table :low_liquidity_quarters do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.string :quarter
      t.integer :year
      t.integer :low_liquidity_days

      t.timestamps
    end
  end
end
