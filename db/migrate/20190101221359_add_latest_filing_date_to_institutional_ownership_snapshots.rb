class AddLatestFilingDateToInstitutionalOwnershipSnapshots < ActiveRecord::Migration
  def change
    add_column :institutional_ownership_snapshots, :latest_filing_date, :date
    add_column :institutional_ownership_snapshots, :scrape_filename, :string
  end
end
