module MarketDataPull
  module TDAmeritrade
    module DailyQuotes
      class FinalizeDailyQuotesFromRealtimeSnapshot < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
        include Verbalize::Action

        def call
          puts "Preparing to finalize DailyStockPrices after real time snapshots - assessing records to be updated"
          records_to_update = DailyStockPrice.where.not(snapshot_time: nil).order(:ticker_symbol, :price_date)
          tickers_to_update = records_to_update.map { |dsp| dsp[:ticker_symbol] }.uniq

          attempts = 0
          tickers_to_update.each do |ticker|
            puts "Updating records for #{ticker}"

            dates_to_update = records_to_update
              .select { |dsp| dsp.ticker_symbol==ticker }
              .map { |dsp| dsp.price_date }
              .reject { |price_date| price_date == Date.current }
            backpopulate_dates_for_symbol(ticker, dates_to_update) if dates_to_update.present?

            attempts = 0
          rescue ::TDAmeritrade::Error::RateLimitError, Timeout::Error => e
            puts "Rate limit error"
            sleep 31
            attempts = attempts + 1
            raise 'TDAmeritrade API Rate Limit error' if attempts >= 3
            retry
          end

          all_dates = records_to_update.map { |dsp| dsp.price_date }.uniq
          all_dates.each { |date| Calculated::PopulateAll.call(date: date) }

          puts "Done with FinalizeDailyQuotesFromRealtimeSnapshot"
        end

      end

      private

      # This uses the historical prices API call to retrieve quotes further back than today
      def backpopulate_dates_for_symbol(symbol, dates)
        BackpopulateDailyStockPricesForSymbol.call(
          symbol: ticker,
          dates: dates_to_update
        )

        DailyStockPrice.where(ticker_symbol: ticker).update_all(snapshot_time: nil)
      end
    end
  end
end