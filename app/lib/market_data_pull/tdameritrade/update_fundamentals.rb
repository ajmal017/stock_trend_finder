module MarketDataPull; module TDAmeritrade
  class UpdateFundamentals < TDAmeritradeAPIBase
    include Verbalize::Action

    def call
      total_count = Ticker.watching.count
      Ticker.watching.each_with_index do |ticker, i|
        next if FundamentalsHistory.find_by(ticker_symbol: ticker.symbol, scrape_date: Date.current).present?
        puts "Updating fundamentals for: #{ticker.symbol} (#{i} of #{total_count})"

        tdaf = with_rate_limit_safeguard { client.get_instrument_fundamentals(ticker.symbol) }
        if tdaf.empty?
          puts "No data returned for #{ticker.symbol}"
          next
        end

        cusip = tdaf[ticker.symbol]["cusip"]
        most_recent_dividend_date = tdaf[ticker.symbol]["fundamental"]["dividendDate"]
        most_recent_dividend_amount = tdaf[ticker.symbol]["fundamental"]["dividendAmount"]
        dividend_yield_pct = tdaf[ticker.symbol]["fundamental"]["dividendYield"] / 100

        # all reported in millions, we store these in thousands
        market_cap = tdaf[ticker.symbol]["fundamental"]["marketCap"] * 1_000
        float = tdaf[ticker.symbol]["fundamental"]["marketCapFloat"] * 1_000
        shares_outstanding = tdaf[ticker.symbol]["fundamental"]["sharesOutstanding"] * 1_000

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
          annual_dividend_amount: calculated_annual_dividend_amount,
          market_cap: market_cap,
          float: float
        )
      end

      puts "Done"
    end

    private

    def client
      @client ||= TDAmeritradeToken.build_client_with_new_access_token
    end

  end
end; end
