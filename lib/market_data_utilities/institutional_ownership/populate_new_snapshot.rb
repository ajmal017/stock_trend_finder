module MarketDataUtilities
  module InstitutionalOwnership
    class PopulateNewSnapshot
      include Verbalize::Action

      input :symbol, :values

      def call
        if values[:institutional_ownership_pct] > 0
          Ticker.find_by(symbol: symbol).update(
            institutional_holdings_percent: values[:institutional_ownership_pct],
            float: (values[:total_shares] / 1000)
          )
        end

        InstitutionalOwnershipSnapshot.create(
          new_record_attributes
        )
      end

      private

      def new_record_attributes
        values.merge({
          ticker_symbol: symbol,
          scrape_date: Date.today,
        })
      end

    end
  end
end