namespace :institutional_ownership_snapshots do

  desc 'Updates the Institutional Ownership Snapshots table'
  task :update => :environment do
    all_tickers = Ticker.where(scrape_data: true).pluck(:symbol)
    all_tickers.each do |symbol|
      values = MarketDataUtilities::InstitutionalOwnership::ScrapeNasdaqPage.(symbol: symbol)
      MarketDataUtilities::InstitutionalOwnership::PopulateNewSnapshot(symbol: symbol, values: values)

      sleep(Random.rand(3..15))
    end
  end
end