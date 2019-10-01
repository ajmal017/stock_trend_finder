class AddTickerSymbolIndexToInstitutionalOwnershipSnapshots < ActiveRecord::Migration
  def change
    add_index "institutional_ownership_snapshots", ["ticker_symbol"], name: "index_ios_symbol", using: :btree
  end
end
