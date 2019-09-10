class AddPriceDateIndexToMarketCapAggregations < ActiveRecord::Migration
  def change
    add_index "market_cap_aggregations", ["price_date"], name: "index_mktcapagg_price_date", using: :btree
  end
end
