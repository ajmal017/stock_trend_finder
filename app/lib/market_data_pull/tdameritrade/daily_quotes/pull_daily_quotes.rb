module MarketDataPull
  module TDAmeritrade
    class PullDailyQuotes < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
      include Verbalize::Action

      # def call
      #   def self.import_quotes(
      #     symbols: [],
      #     begin_date: nil,
      #     end_date: Date.today,
      #   )
      #     cache_file =  File.join(Rails.root, 'downloads', "tdameritrade_daily_stock_prices_cache.csv")
      #
      #     symbols.each.with_index(1) do |symbol, i|
      #       reset_attempts
      #       puts "Processing #{i}: #{symbol}"
      #       begin
      #         error_count = 0
      #         prices = Array.new
      #         last_dsp = DailyStockPrice.where(ticker_symbol: symbol).order(price_date: :desc).first
      #
      #         while error_count < 3 && error_count != -1 # error count should be -1 on a successful download of data
      #           if last_dsp.present?
      #             if last_dsp.price_date == end_date
      #               prices = [{already_processed: true}]
      #             else
      #               if begin_date.nil?
      #                 prices = c.get_daily_price_history(symbol, (last_dsp.price_date+1), end_date)
      #               else
      #                 prices = c.get_daily_price_history(symbol, begin_date, end_date)
      #               end
      #             end
      #           else
      #             prices = c.get_daily_price_history(symbol, NEW_TICKER_BEGIN_DATE, end_date)
      #           end
      #           if get_history_returned_error?(prices)
      #             # TODO Change this so that it handles an exception rather than checks for error condition
      #             error_count += 1
      #             puts "Error processing #{symbol} - (attempt ##{error_count}) #{prices.first[:error]}"
      #             log = log + "Error processing #{symbol} - (attempt ##{error_count}) #{prices.first[:error]}\n"
      #           else
      #             error_count = -1
      #           end
      #         end
      #
      #         next if get_history_returned_error?(prices) || prices.first.has_key?(:already_processed)
      #
      #         of = open(cache_file, "w")
      #         of.write("ticker_symbol,price_date,open,high,low,close,volume,created_at,updated_at\n")
      #
      #         price_date_list=Array.new
      #         prices.each do |bar|
      #           if price_date_list.index(bar[:timestamp]).nil?
      #             of.write "#{symbol},#{bar[:timestamp].month}/#{bar[:timestamp].day}/#{bar[:timestamp].year},#{bar[:open]},#{bar[:high]},#{bar[:low]},#{bar[:close]},#{bar[:volume]/10},'#{Time.now}','#{Time.now}'\n"
      #             price_date_list << bar[:timestamp]
      #           end
      #         end
      #         of.close
      #       rescue ::TDAmeritrade::Error::RateLimitError => e
      #         handle_rate_limit_error && retry
      #       rescue => e
      #         puts "Error processing #{symbol} - #{e.message}"
      #         next
      #       end
      #
      #       begin
      #         ActiveRecord::Base.connection.execute(
      #           "COPY daily_stock_prices (ticker_symbol,price_date,open,high,low,close,volume,created_at,updated_at)
      #         FROM '#{cache_file}'
      #         WITH (FORMAT 'csv', HEADER)"
      #         )
      #
      #       rescue => e
      #         puts "#{e.message}"
      #       end
      #
      #     end
      #
      # end
      #
      # private
      #

    end
  end
end