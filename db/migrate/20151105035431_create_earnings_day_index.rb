class CreateEarningsDayIndex < ActiveRecord::Migration
  def change
    add_index "earnings_days", ["earnings_date", "before_the_open"], name: "index_earnings_days_date", unique: true, using: :btree
  end
end
