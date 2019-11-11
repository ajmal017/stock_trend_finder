# frozen_string_literal: true
module MarketDataPull; module TDAmeritrade; module DailyQuotes
  class PullRealTimeQuotes < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    CACHE_FILE = File.join(Rails.root, 'downloads', "tdameritrade_daily_stock_prices_cache.csv")

    input optional: [:premarket]

    def call
      RealTimeQuote.reset_cache

      while ((batch = ticker_watch_list.slice!(0,250)) != [])
        quotes = {}
        with_rate_limit_safeguard do
          quotes = client.get_quotes(batch)
        end

        begin
          of = open(CACHE_FILE, "w")
          of.write("ticker_symbol,last_trade,quote_time,open,high,low,volume\n")

          quotes.keys.each do |symbol|
            begin
              candle = quotes[symbol]

              if candle_is_valid?(candle)
                line =
                  "#{symbol}," \
                  "#{candle['mark']}," \
                  "#{candle['tradeTimeInLong'] > 0 ? long_to_time(candle['tradeTimeInLong']).to_s : nil}," \
                  "#{candle['openPrice']}," \
                  "#{candle['highPrice']}," \
                  "#{candle['lowPrice']}," \
                  "#{candle['totalVolume']}\n"

                of.write(line)
              end
            rescue StandardError => e
              puts "Error processing #{symbol} - #{e.message}"
              next
            end
          end
        ensure
          of.close
        end

        begin
          ActiveRecord::Base.connection.execute(
            "COPY real_time_quotes (ticker_symbol,last_trade,quote_time,open,high,low,volume)
              FROM '#{CACHE_FILE}'
              WITH (FORMAT 'csv', HEADER)"
          )
        rescue => e
          puts "#{e.message}"
          log = log + "#{e.message}\n"
        end

      end
    end

    private

    def candle_is_valid?(candle)
      (premarket? && candle['mark'] > 0 && candle['totalVolume'] > 0) ||
      (candle['mark'] > 0 && candle['openPrice'] > 0 && candle['highPrice'] > 0 && candle['lowPrice'] > 0)
    end

    def premarket?
      @premarket || false
    end

    def ticker_watch_list
      @ticker_watch_list ||= Ticker.watching.pluck(:symbol)
    end

  end
end; end; end

