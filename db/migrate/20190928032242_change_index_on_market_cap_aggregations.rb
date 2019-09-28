class ChangeIndexOnMarketCapAggregations < ActiveRecord::Migration
  def change
    remove_index "market_cap_aggregations", name: "index_mktcapagg_price_date"
    add_index "market_cap_aggregations", ["price_date", "bucket", "bucket_type"], name: "index_mktcapagg_price_date", unique: true, using: :btree
  end
end
