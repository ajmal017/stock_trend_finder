namespace :institutional_ownership_snapshots do

  desc 'Updates the Institutional Ownership Snapshots table'
  task :update => :environment do
    MarketDataUtilities::InstitutionalOwnership::ScrapeAll.call
  end
end