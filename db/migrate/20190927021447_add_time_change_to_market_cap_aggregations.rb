class AddTimeChangeToMarketCapAggregations < ActiveRecord::Migration
  def change
    add_column :market_cap_aggregations, :change_pct_1_day, :decimal, precision: 5,  scale: 2
    add_column :market_cap_aggregations, :change_pct_10_day, :decimal, precision: 5,  scale: 2
    add_column :market_cap_aggregations, :change_pct_30_day, :decimal, precision: 5,  scale: 2
    add_column :market_cap_aggregations, :change_pct_90_day, :decimal, precision: 5,  scale: 2
  end
end
