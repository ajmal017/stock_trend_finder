# frozen_string_literal: true
module MarketDataPull; module TDAmeritrade; module DailyQuotes
  class PullRealTimeQuotes < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    CACHE_FILE = File.join(Rails.root, 'downloads', "tdameritrade_daily_stock_prices_cache.csv")

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
              bar = quotes[symbol]

              if bar['mark'] > 0 && bar['openPrice'] > 0 && bar['highPrice'] > 0 && bar['lowPrice'] > 0
                line =
                  "#{symbol}," \
                  "#{bar['mark']}," \
                  "#{bar['tradeTimeInLong'] > 0 ? long_to_time(bar['tradeTimeInLong']).to_s : nil}," \
                  "#{bar['openPrice']}," \
                  "#{bar['highPrice']}," \
                  "#{bar['lowPrice']}," \
                  "#{bar['totalVolume']}\n"

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

    def ticker_watch_list
      @ticker_watch_list ||= Ticker.watching.pluck(:symbol)
    end

  end
end; end; end

