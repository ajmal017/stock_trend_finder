module MarketDataPull
  module TDAmeritrade
    module DailyQuotes
      class FinalizeDailyQuotesFromRealtimeSnapshot < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
        include Verbalize::Action

        input optional: [:begin_date, :end_date, :symbols]

        # def call
        #   validate - since it will use the get_quotes method, this can only be run on the current DailyStockPrice day
        #            - otherwise you need to use the BackpopulateDailyStockPricesForSymbol interactor
        #
        #   puts "Preparing to update DailyStockPrices - assessing records to be updated"
        #   records_to_update = DailyStockPrice.where.not(snapshot_time: nil).order(:ticker_symbol, :price_date)
        #   price_dates_to_update = records_to_update.map {|dsp| dsp[:price_date] }.uniq
        #
        #   price_dates_to_update.each do |price_date|
        #     puts "Updating records from #{price_date}"
        #
        #     total_count = records_to_update.count
        #     counter = 1
        #     records_to_update.select { |dsp| dsp[:price_date]==price_date }.map { |dsp| dsp[:ticker_symbol] }.each_slice(100) do |tickers|
        #       begin
        #         quote_bunch=[]
        #         2.times.each do |error_count|
        #           begin
        #             quote_bunch = c.get_price_history(tickers, intervaltype: :daily, intervalduration: 1, startdate: price_date, enddate: price_date)
        #             break
        #           rescue Exception => e
        #             #TODO figure out what causes it - why we trying to get records that dont exist
        #             puts "Error processing - #{e.message} - attempt (#{error_count + 1})"
        #             log = log + "Error processing - #{e.message} - attempt (#{error_count + 1})\n"
        #             sleep Random.rand(15)
        #           end
        #         end
        #
        #         next if quote_bunch.empty?
        #         quote_bunch.each do |quotes|
        #           next if quotes[:symbol].nil? || quotes[:bars].nil? || quotes[:bars].length < 1
        #           ticker_symbol = quotes[:symbol].to_s
        #           prices = quotes[:bars]
        #
        #           p = prices.first
        #           puts "Processing #{counter} of #{total_count}: #{p[:symbol]}"; counter += 1
        #
        #
        #           if p[:timestamp].to_date != price_date
        #             puts "Error: price date does not match"
        #             log = log + "Error processing #{p[:symbol]}: incorrect price date #{p[:timestamp]} vs #{price_date} in the record"
        #             next
        #           end
        #           new_attributes = {
        #             open: p[:open],
        #             high: p[:high],
        #             low: p[:low],
        #             close: p[:close].to_f.round(2),
        #             volume: p[:volume]/10,
        #             # previous_close: nil,  # why was I resetting these before?
        #             # previous_high: nil,
        #             # previous_low: nil,
        #             # average_volume_50day: nil,
        #             snapshot_time: nil
        #           }
        #
        #           dsp = DailyStockPrice.where(ticker_symbol: ticker_symbol, price_date: price_date).first
        #           if dsp.present?
        #             dsp.update_attributes(new_attributes)
        #           end
        #         end
        #
        #       end
        #     end
        #
        #   end
        #
        # end

        def self.update_daily_stock_prices_from_real_time_snapshot(opts={})


          i = 1


          puts log

          puts "Updating Previous Close Cache - #{Time.now}"
          populate_previous_close

          puts "Calculating Average Daily Volumes - #{Time.now}"
          populate_average_volume_50day(NEW_TICKER_BEGIN_DATE)

          puts "Updating Previous High Cache - #{Time.now}"
          populate_previous_high

          puts "Updating Previous Low Cache - #{Time.now}"
          populate_previous_low

          puts "Updating 52 Week High Cache - #{Time.now}"
          populate_high_52_weeks

          puts "Updating 52 Week Low Cache - #{Time.now}"
          populate_low_52_weeks

          puts "Calculating SMA50's - #{Time.now}"
          populate_sma50

          puts "Calculating SMA200's - #{Time.now}"
          populate_sma200

          log_problem_tickers=""
          log.lines.each do |line|
            log_problem_tickers+="#{/Error processing (.*?) -/.match(line)[1]}," if /\b#{/Error processing (.*?) -/.match(line)[1]}\b/.match(log_problem_tickers).nil?
          end
          log_problem_tickers.slice!(log_problem_tickers.length-1) if log_problem_tickers.last==","
          puts "Summary report of problem tickers: #{log_problem_tickers}"

        end


      end
    end
  end
end