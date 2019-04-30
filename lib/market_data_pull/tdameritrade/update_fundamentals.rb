module MarketDataPull
  module TDAmeritrade
    class UpdateFundamentals
      include Verbalize::Action

      def call
        attempts = 0
        Ticker.watching.each do |ticker|
          next if FundamentalsHistory.find_by(ticker_symbol: ticker.symbol, scrape_date: Date.current).present?
          puts "Updating fundamentals for: #{ticker.symbol}"

          tdaf = client.get_instrument_fundamentals(ticker.symbol)
          next if tdaf.empty?

          cusip = tdaf[ticker.symbol]["cusip"]
          most_recent_dividend_date = tdaf[ticker.symbol]["fundamental"]["dividendDate"]
          most_recent_dividend_amount = tdaf[ticker.symbol]["fundamental"]["dividendAmount"]
          dividend_yield_pct = tdaf[ticker.symbol]["fundamental"]["dividendYield"] / 100

          # all reported in millions
          market_cap = tdaf[ticker.symbol]["fundamental"]["marketCap"] / 1_000_000
          float = tdaf[ticker.symbol]["fundamental"]["marketCapFloat"] / 1_000_000
          shares_outstanding = tdaf[ticker.symbol]["fundamental"]["sharesOutstanding"] / 1_000_000

          dsp = DailyStockPrice.most_recent(ticker.symbol)
          calculated_annual_dividend_amount =
            dsp&.close.is_a?(Numeric) ? dividend_yield_pct * dsp.close : 0

          FundamentalsHistory.find_or_create_by(
            ticker_symbol: ticker.symbol,
            cusip: cusip,
            scrape_date: Date.current,
            most_recent_dividend_date: most_recent_dividend_date,
            most_recent_dividend_amount: most_recent_dividend_amount,
            dividend_yield_pct: dividend_yield_pct,
            calculated_annual_dividend_amount: calculated_annual_dividend_amount,
            market_cap: market_cap,
            shares_outstanding: shares_outstanding,
            float: float,
          )

          Ticker.where(symbol: ticker.symbol).update_all(
            annual_dividend_amount: calculated_annual_dividend_amount
          )

          attempts = 0
          sleep 0.9 # Rate limit of 2 requests per second
        rescue TDAmeritrade::Error::RateLimitError => e
          sleep 31
          attempts = attempts + 1
          raise 'TDAmeritrade API error' if attempts >= 3
          retry
        end

        puts "Done"
      end

      private

      def client
        @client ||= TDAmeritradeToken.build_client
      end

    end
  end
end
