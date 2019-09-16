module MarketDataPull
  module TDAmeritrade
    module DailyQuotes
      class BackpopulateDailyStockPricesForSymbol < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
        include StockMarketDays
        include Verbalize::Action

        input :symbol, :dates

        def call
          puts "Backpopulating #{symbol} for #{dates}"
          period_values = period_values_for_date

          price_history = client.get_price_history(
            symbol,
            frequency: 1,
            frequency_type: :daily,
            period_type: period_values[:period_type],
            period: period_values[:period]
          )
          if price_history['candles'].empty?
            puts "No candles returned for #{symbol}"
          end

          market_dates.each do |date|
            candle = price_history['candles'].find { |ph| ph['datetime']&.to_date == date }
            next if candle.nil?

            dsp = DailyStockPrice.find_by(ticker_symbol: symbol, price_date: date)
            if dsp.nil?
              DailyStockPrice.create(
                ticker_symbol: symbol,
                price_date: date,
                open: candle['open'],
                high: candle['high'],
                low: candle['low'],
                close: candle['close'],
                volume: candle['volume'].try(:/, 1000)
              )
            else
              dsp.update(
                open: candle['open'],
                high: candle['high'],
                low: candle['low'],
                close: candle['close'],
                volume: candle['volume'].try(:/, 1000)
              )
            end
          end
        end

        private

        def start_date
          market_dates.min
        end

        def end_date
          Date.current
        end

        def market_dates
          dates.uniq.sort.select { |d| StockMarketDays.is_market_day?(d) }
        end

        # For some strange reason this returns bad request... can't query daily candles using start/end date:
        # client.get_price_history('MSFT', frequency_type: :daily, frequency: 1, start_date: Date.new(2019,9,11), end_date: Date.new(2019,9,13))
        # ... so I had to come up with this elaborate system
        def period_values_for_date
          interval_between = Date.current.to_time - start_date.to_time
          if interval_between > 10.years
            { period_type: :year, period: 20 }
          elsif interval_between > 5.years
            { period_type: :year, period: 10 }
          elsif interval_between > 3.years
            { period_type: :year, period: 5 }
          elsif interval_between > 2.years
            { period_type: :year, period: 3 }
          elsif interval_between > 1.years
            { period_type: :year, period: 2 }
          elsif interval_between > 6.months
            { period_type: :year, period: 1 }
          elsif interval_between > 3.months
            { period_type: :month, period: 6 }
          elsif interval_between > 2.months
            { period_type: :month, period: 3 }
          elsif interval_between > 1.month
            { period_type: :month, period: 2 }
          else
            { period_type: :month, period: 1 }
          end
        end

      end
    end
  end
end