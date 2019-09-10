class CreateMarketCapAggregations < ActiveRecord::Migration
  def change
    create_table :market_cap_aggregations do |t|
      t.date :price_date
      t.string :bucket_type
      t.string :bucket
      t.decimal :market_cap

      t.timestamps null: false
    end
  end
end
