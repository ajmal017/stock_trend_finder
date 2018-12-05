module MarketDataPull
  module TDAmeritrade
    class UpdateFundamentals
      include Verbalize::Action

      def call
        Ticker.watching.each do |ticker|
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
          calculated_annual_dividend_amount = dividend_yield_pct / dsp.close

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

          Ticker.where(symbol: ticker.symbol).update_all(annual_dividend_amount: calculated_annual_dividend_amount)

          sleep 0.6 # Rate limit of 2 requests per second
        end
      end

      private

      def client
        @client ||= TDAmeritradeToken.build_client
      end

    end
  end
end