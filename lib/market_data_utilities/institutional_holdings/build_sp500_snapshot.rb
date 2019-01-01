module MarketDataUtilities
  module InstitutionalHoldings
    class BuildSP500Snapshot
      include Verbalize::Action

      input :date

      def call
        result = CalculateSP500
        .call(date: date)
        .value
        .merge(ticker_symbol: 'SP500', scrape_date: date)

        InstitutionalOwnershipSnapshot.create!(result)
      end

    end
  end
end