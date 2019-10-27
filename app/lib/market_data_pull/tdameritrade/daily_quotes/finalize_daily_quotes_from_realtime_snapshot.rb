module MarketDataPull
  module TDAmeritrade
    module DailyQuotes
      class FinalizeDailyQuotesFromRealtimeSnapshot < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
        include Verbalize::Action

        def call
          puts "Preparing to finalize DailyStockPrices after real time snapshots - assessing records to be updated"
          tickers_to_update = records_to_update.map { |dsp| dsp[:ticker_symbol] }.uniq

          tickers_to_update.each do |ticker|
            puts "Updating records for #{ticker}"

            with_rate_limit_safeguard do
              dates_to_update = records_to_update
                .select { |dsp| dsp.ticker_symbol==ticker }
                .map { |dsp| dsp.price_date }
              backpopulate_dates_for_symbol(ticker, dates_to_update) if dates_to_update.present?
            end
          end

          all_dates = records_to_update.map { |dsp| dsp.price_date }.uniq
          all_dates.each { |date| Calculated::PopulateAll.call(date: date) }

          puts "Done with FinalizeDailyQuotesFromRealtimeSnapshot"
        end

      end

      private

      # This uses the historical prices API call to retrieve quotes further back than today
      def backpopulate_dates_for_symbol(symbol, dates)
        BackpopulateDailyStockPricesForSymbol.call(symbol: symbol, dates: dates)
        DailyStockPrice.where(ticker_symbol: ticker).update_all(snapshot_time: nil)
      end

      def records_to_update
        @records_to_update ||=
          DailyStockPrice
            .where("price_date > ?", Date.today - 20.days)
            .where.not(snapshot_time: nil)
            .order(:ticker_symbol, :price_date)
      end

    end
  end
end