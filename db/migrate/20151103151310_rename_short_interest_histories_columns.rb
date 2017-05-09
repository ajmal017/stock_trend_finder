class RenameShortInterestHistoriesColumns < ActiveRecord::Migration
  def change
    rename_column :short_interest_histories, :as_of_date, :short_interest_date
    rename_column :short_interest_histories, :shares_short_pct_float, :short_pct_float
    add_index "short_interest_histories", [:ticker_symbol, :short_interest_date],
              name: "index_on_short_interest_histories_ticker_sid",
              using: :btree,
              unique: true
  end
end
