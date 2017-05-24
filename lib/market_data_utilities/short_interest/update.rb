module MarketDataUtilities
  module ShortInterest
    class Update
      include Verbalize::Action

      def call
        MarketDataUtilities::Yahoo::UpdateFloats.update_floats
        MarketDataUtilities::Nasdaq::ScrapeAll.call

        MarketDataUtilities::Yahoo::UpdateFloats.update_floats
      end

      def most_recent_short_nasdaq_interest_history_date
        ShortInterestHistory.where(source: 'nasdaq').order(short_interest_date: :desc).last.short_interest_date
      end

      def ticker_symbols_not_updated_by_nasdaq
        Ticker.watching.pluck(:symbol) - ShortInterestHistory.where(short_interest_date: Date.new(2017,4,28)).pluck(:ticker_symbol)
      end

    end
  end
end