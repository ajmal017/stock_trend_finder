module MarketDataPull; module Nasdaq; module InstitutionalHoldings
  class ScrapeAll
    include Verbalize::Action

    def call
      errors = 0
      symbols.each_with_index do |symbol, i|
        puts "Pulling institutional holdings snapshot for #{symbol} (#{i + 1} of #{symbols.size})"
        SaveOwnershipSnapshotForSymbol.call(symbol: symbol)
        sleep(Random.rand(1..8))
      rescue StandardError
        if errors > 10
          puts "Something is wrong scraping. Aborting"
          return
        else
          errors += 1
          next
        end
      end
    end

    private

    def symbols
      @symbols ||=
        (Ticker.watching.pluck(:symbol)) - symbols_processed_today
    end

    def symbols_processed_today
      Ticker
        .where("institutional_ownership_snapshots.scrape_date = ?", Date.current)
        .joins(:institutional_ownership_snapshots)
        .pluck(:symbol)
    end


  end
end; end; end