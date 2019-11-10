require 'tdameritrade_data_interface/run_daemons'
require 'tdameritrade_data_interface/sql_query_strings'
require 'tdameritrade_data_interface/util'
require 'evernote/evernote_watchlist'

module TDAmeritradeDataInterface
  extend RunDaemons
  include SQLQueryStrings

  def self.defunct_tickers
    scrape = Ticker.watching.pluck(:symbol)
    scrape.select { |ticker| DailyStockPrice.where("ticker_symbol=? AND price_date=?", ticker, Date.today-20).count == 0 }
  end

  def self.prepopulate_daily_stock_prices(prepopulate_date)
    if is_market_day?(prepopulate_date)
      puts "Prepopulating Daily Stock Prices for #{prepopulate_date} - #{Time.now}"
      puts "Prepopulating Previous Close, Previous High, Previous Low - #{Time.now}"
      ActiveRecord::Base.connection.execute insert_daily_stock_prices_prepopulated_fields(prepopulate_date)

      puts "Prepopulating Average Daily Volumes - #{Time.now}"
      populate_average_volume_50day(prepopulate_date)

      puts "Prepopulating SMA50 - #{Time.now}"
      populate_sma50(prepopulate_date)

      puts "Prepopulating SMA200 - #{Time.now}"
      populate_sma200(prepopulate_date)

      puts "Prepopulating 52 Week Highs - #{Time.now}"
      populate_high_52_weeks(prepopulate_date)
      populate_premarket_high_52_weeks(prepopulate_date)

      puts "Prepopulating 52 Week Lows - #{Time.now}"
      populate_low_52_weeks(prepopulate_date)
      populate_premarket_low_52_weeks(prepopulate_date)

      puts "Prepopulating 52 Week High Streak - #{Time.now}"
      populate_high_52_week_streak(prepopulate_date)

      puts "Prepopulating 52 Week Low Streak - #{Time.now}"
      populate_low_52_week_streak(prepopulate_date)

      puts "Done prepopulating Daily Stock Prices - #{Time.now}"
    else
      puts "Market closed today, no prepopulation necessary"
    end
  end

  # DEPRECATED Just leaving this here for emergency rollback in initial week of testing
  def self.import_premarket_quotes(opts={})
    date = opts[:date]
    if !date.is_a? Date
      puts "Invalid date submitted to import_premarket quotes"
      return
    end

    puts "#{Time.now}: Downloading premarket quotes for #{date}"
    log_file = File.join(Rails.root, 'downloads', 'import_premarket_quotes.log')

    c = TDAmeritradeApi::Client.new
    c.login
    log = ""

    #alltickers = DailyStockPrice.where(price_date: date).pluck(:ticker_symbol) && Ticker.watching.pluck(:symbol)
    alltickers = Ticker.watching.pluck(:symbol)


    i = 1
    alltickers.each_slice(100) do |tickers|
      begin
        error_count=0
        while error_count < 3 && error_count != -1 # error count should be -1 on a successful download of data
          begin
            quote_bunch = c.get_price_history(tickers, intervaltype: :minute, intervalduration: 5, startdate: date, enddate: date, extended: true)
            error_count = -1 if quote_bunch
          rescue Exception => e
            error_count += 1
            puts "Error processing - #{e.message} - attempt (#{error_count})"
            log = log + "Error processing - #{e.message} - attempt (#{error_count})\n"
            sleep 10
          end
        end
        quote_bunch.each do |quotes|
          next if quotes[:symbol].nil? || quotes[:bars].nil? || quotes[:bars].length < 1
          ticker_symbol = quotes[:symbol].to_s
          prices = quotes[:bars].select { |bar| bar[:timestamp] < Time.parse(bar[:timestamp].strftime('%a, %d %b %Y 09:30:00')) }

          if prices.empty? || prices.first[:close]==0
            puts "#{date} Skipping #{i}: #{ticker_symbol} - no PM prints"
          else
            puts "#{date} Processing #{i}: #{ticker_symbol}"

            latest_bar = prices.inject { |latest, bar| bar[:timestamp] > latest[:timestamp] && bar[:timestamp] < Time.parse(bar[:timestamp].strftime('%a, %d %b %Y 09:30:00')) ? bar : latest }
            fields = {
                ticker_symbol: ticker_symbol,
                price_date: date,
                latest_print_time: latest_bar[:timestamp],
                last_trade: latest_bar[:close].round(2),
                high: latest_bar[:high].round(2),
                low: latest_bar[:low].round(2),
                volume: (prices.inject(0) { |volume_sum, bar| bar[:timestamp] <= latest_bar[:timestamp] ? volume_sum + bar[:volume] : volume_sum } / 10).round(2)
            }

            pm = PremarketPrice.where(ticker_symbol: ticker_symbol, price_date: date).first
            if pm.present?
              pm.update_attributes(fields)
            else
              PremarketPrice.create(fields)
            end
          end
          i += 1
        end

      rescue => e
        puts "Error processing - #{e.message}"
        log = log + "Error processing - #{e.message}\n"
        next
      end

    end
    puts log

    of = open(log_file, "w")
    of.write(log)
    of.close

    # puts "Copying Memoized Premarket Previous Close, High, Low, and Average Daily Volumes - #{Time.now}"
    # copy_memoized_fields_to_premarket_prices date

    # puts "Updating Premarket Previous Close Cache - #{Time.now}"
    # populate_premarket_previous_close date
    #
    # puts "Updating Premarket Previous High Cache - #{Time.now}"
    # populate_premarket_previous_high date
    #
    # puts "Updating Premarket Previous Low Cache - #{Time.now}"
    # populate_premarket_previous_low date
    #
    # puts "Calculating Premarket Average Daily Volumes - #{Time.now}"
    # populate_premarket_average_volume_50day(date)
    ::MarketDataPull::TDAmeritrade::PremarketQuotes::Calculated::PopulateAll.call(date: Date.current)

    puts "Done"
  end

  def self.import_afterhours_quotes(opts={})
    date = opts[:date]
    if !date.is_a? Date
      puts "Invalid date submitted to import_afterhours_quotes"
      return
    end

    log_file = File.join(Rails.root, 'downloads', 'import_afterhours_quotes.log')

    c = TDAmeritradeApi::Client.new
    c.login
    log = ""

    #alltickers = DailyStockPrice.where(price_date: date).pluck(:ticker_symbol) && Ticker.watching.pluck(:symbol)
    alltickers = Ticker.watching.pluck(:symbol)

    i = 1
    alltickers.each_slice(100) do |tickers|
      begin
        error_count=0
        while error_count < 3 && error_count != -1 # error count should be -1 on a successful download of data
          begin
            quote_bunch = c.get_price_history(tickers, intervaltype: :minute, intervalduration: 5, startdate: date, enddate: date, extended: true)
            # binding.pry if tickers.include?('XIV') && $stop
            error_count = -1 if quote_bunch
          rescue Exception => e
            error_count += 1
            puts "Error processing - #{e.message} - attempt (#{error_count})"
            log = log + "Error processing - #{e.message} - attempt (#{error_count})\n"
            sleep 10
          end
        end
        quote_bunch.each do |quotes|
          next if quotes[:symbol].nil? || quotes[:bars].nil? || quotes[:bars].length < 1
          ticker_symbol = quotes[:symbol].to_s
          prices = quotes[:bars].select { |bar| bar[:timestamp] >= Time.parse(bar[:timestamp].strftime('%a, %d %b %Y 16:05:00')) }

          # binding.pry if quotes[:symbol] == 'XIV' && $stop
          if prices.empty?
            puts "#{date} Skipping #{i}: #{ticker_symbol} - no AH prints"
          else
            puts "#{date} Processing #{i}: #{ticker_symbol}"

            latest_bar = prices.inject { |latest, bar| bar[:timestamp] > latest[:timestamp] && bar[:timestamp] > Time.parse(bar[:timestamp].strftime('%a, %d %b %Y 16:10:00')) ? bar : latest }
            fields = {
                ticker_symbol: ticker_symbol,
                price_date: date,
                latest_print_time: latest_bar[:timestamp],
                last_trade: latest_bar[:close].round(2),
                high: latest_bar[:high].round(2),
                low: latest_bar[:low].round(2),
                volume: (prices.inject(0) { |volume_sum, bar| bar[:timestamp] <= latest_bar[:timestamp] ? volume_sum + bar[:volume] : volume_sum } / 10).round(2)
            }

            ah = AfterHoursPrice.where(ticker_symbol: ticker_symbol, price_date: date).first
            if ah.present?
              ah.update_attributes(fields)
            else
              AfterHoursPrice.create(fields)
            end
          end
          i += 1
        end

      rescue => e
        puts "Error processing - #{e.message}"
        log = log + "Error processing - #{e.message}\n"
        next
      end

    end
    puts log

    of = open(log_file, "w")
    of.write(log)
    of.close

    puts "Updating After Hours Previous Close Cache - #{Time.now}"
    populate_afterhours_intraday_close NEW_TICKER_BEGIN_DATE

    puts "Updating After Hours Previous High Cache - #{Time.now}"
    populate_afterhours_intraday_high NEW_TICKER_BEGIN_DATE

    puts "Updating After Hours Previous Low Cache - #{Time.now}"
    populate_afterhours_intraday_low NEW_TICKER_BEGIN_DATE

    puts "Calculating After Hours Average Daily Volumes - #{Time.now}"
    populate_afterhours_average_volume_50day(NEW_TICKER_BEGIN_DATE)

    puts "Done"
  end

  def self.reset_snapshot_flags
    ActiveRecord::Base.connection.execute update_reset_snapshot_flags
  end

  # WARNING THIS FUNCTION IS BROKEN - NEEDS TO BE UPDATED TO USE NEW API CALLS
  # def self.catch_up(date, vacuum=true)
  #   unless date.is_a? Date
  #     puts "Enter an input date"
  #     return
  #   end
  #
  #   prepopulate_daily_stock_prices(date)
  #   DailyStockPrice.where(price_date: date).update_all(snapshot_time: date)
  #
  #   # update_daily_stock_prices_from_real_time_snapshot
  #   # import_premarket_quotes(date: date)
  #   # import_afterhours_quotes(date: date)
  #
  #   if vacuum
  #     ActiveRecord::Base.connection.execute "VACUUM FULL"
  #     ActiveRecord::Base.connection.execute "VACUUM ANALYZE"
  #   end
  # end

  def self.populate_high_52_weeks(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_high_52_week(begin_date)
  end

  def self.populate_low_52_weeks(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_low_52_week(begin_date)
  end

  def self.populate_high_52_week_streak(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_high_52_week_streak(begin_date)
  end

  def self.populate_low_52_week_streak(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_low_52_week_streak(begin_date)
  end

  def self.populate_premarket_high_52_weeks(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_premarket_high_52_week(begin_date)
  end

  def self.populate_premarket_low_52_weeks(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_premarket_low_52_week(begin_date)
  end

  def self.populate_previous_close(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_previous_close(begin_date)
  end

  def self.populate_previous_high(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_previous_high(begin_date)
  end

  def self.populate_previous_low(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_previous_low(begin_date)
  end

  def self.populate_average_volume_50day(begin_date=Date.today)
    ActiveRecord::Base.connection.execute update_average_volume_50day(begin_date)
  end

  def self.populate_sma50(date=Date.today)

    begin
      # Populate the first entry - sma13
      ActiveRecord::Base.connection.execute update_sma50(date)

    rescue => e
      puts "#{e.message}"
      log = log + "#{e.message}\n"
    end

  end

  def self.populate_sma200(date=Date.today)

    begin
      # Populate the first entry - sma13
      ActiveRecord::Base.connection.execute update_sma200(date)

    rescue => e
      puts "#{e.message}"
      log = log + "#{e.message}\n"
    end

  end

  def self.populate_premarket_previous_close(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_premarket_prices_previous_close(begin_date)
  end

  def self.populate_premarket_previous_high(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_premarket_prices_previous_high(begin_date)
  end

  def self.populate_premarket_previous_low(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_premarket_prices_previous_low(begin_date)
  end

  def self.populate_premarket_average_volume_50day(begin_date=Date.today)
    ActiveRecord::Base.connection.execute update_premarket_prices_average_volume_50day(begin_date)
  end

  def self.populate_premarket_memoized_fields(date=Date.today)
    ActiveRecord::Base.connection.execute "TRUNCATE TABLE memoized_fields"
    ActiveRecord::Base.connection.execute insert_memoized_tickers(date)
    ActiveRecord::Base.connection.execute update_memoized_premarket_average_volume_50day(date)
    ActiveRecord::Base.connection.execute update_memoized_premarket_previous_high(date)
    ActiveRecord::Base.connection.execute update_memoized_premarket_previous_low(date)
    ActiveRecord::Base.connection.execute update_memoized_premarket_previous_close(date)
  end

  def self.copy_memoized_fields_to_premarket_prices(date=Date.today)
    ActiveRecord::Base.connection.execute insert_memoized_fields_into_premarket_prices(date)
  end

  def self.populate_afterhours_intraday_close(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_afterhours_prices_intraday_close(begin_date)
  end

  def self.populate_afterhours_intraday_high(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_afterhours_prices_intraday_high(begin_date)
  end

  def self.populate_afterhours_intraday_low(begin_date=NEW_TICKER_BEGIN_DATE)
    ActiveRecord::Base.connection.execute update_afterhours_prices_intraday_low(begin_date)
  end

  def self.populate_afterhours_average_volume_50day(begin_date=Date.today)
    ActiveRecord::Base.connection.execute update_afterhours_prices_average_volume_50day(begin_date)
  end

  def self.copy_realtime_quotes_to_daily_stock_prices
    DailyStockPrice.transaction do
      puts "Inserting daily stock prices #{Time.now}"
      ActiveRecord::Base.connection.execute insert_daily_stock_prices_from_realtime_quotes
      puts "Updating daily stock prices #{Time.now}"
      ActiveRecord::Base.connection.execute update_daily_stock_prices_from_realtime_quotes

      puts "Updating Previous Close Cache - #{Time.now}"
      populate_previous_close(Date.today)

      puts "Updating Previous High Cache - #{Time.now}"
      populate_previous_high(Date.today)

      puts "Updating Previous Low Cache - #{Time.now}"
      populate_previous_low(Date.today)

      puts "Calculating Average Daily Volumes - #{Time.now}"
      populate_average_volume_50day(Date.today)

      puts "Calculating SMA50's - #{Time.now}"
      populate_sma50(Date.today)

      puts "Calculating SMA200's - #{Time.now}"
      populate_sma200(Date.today)

      puts "Done"
    end
  end


  private

  def self.get_history_returned_error?(return_value)
    if return_value.is_a? Array and return_value.length > 0
      return return_value.first.has_key?(:error)
    else
      raise "Error: get_daily_price_history() returned an invalid object"
    end
  end

end