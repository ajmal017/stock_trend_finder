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

  def self.quick_reset_ticker_symbol(symbol)
    DailyStockPrice.where(ticker_symbol: symbol).delete_all
    import_quotes(symbols: [symbol])
  end

  def self.import_quotes(opts={})
    begin_date = (opts.has_key? :begin_date) && (opts[:begin_date].is_a? Date) ? opts[:begin_date] : nil
    end_date = (opts.has_key? :end_date) && (opts[:end_date].is_a? Date) ? opts[:end_date] : Date.today
    #end_date = (opts.has_key? :end_date) && (opts[:end_date].is_a? Date) ? opts[:end_date].strftime('%Y%m%d') : Date.today.strftime('%Y%m%d')

    cache_file =  File.join(Rails.root, 'downloads', "tdameritrade_daily_stock_prices_cache.csv")
    log_file = File.join(Rails.root, 'downloads', 'import_quotes.log')

    c = TDAmeritradeApi::Client.new
    c.login
    log = ""
    #c.session_id = "128459556EEA989391FBAAA5E2BF8EB4.cOr5v8xckaAXQxWmG7bn2g"

    symbols = opts[:symbols] || Ticker.watching.map(&:symbol)
    symbols.each.with_index(1) do |symbol, i|
      puts "Processing #{i}: #{symbol}"
      begin
        error_count = 0
        prices = Array.new
        last_dsp = DailyStockPrice.where(ticker_symbol: symbol).order(price_date: :desc).first

        while error_count < 3 && error_count != -1 # error count should be -1 on a successful download of data
          if last_dsp.present?
            if last_dsp.price_date == end_date
              prices = [{already_processed: true}]
            else
              if begin_date.nil?
                prices = c.get_daily_price_history(symbol, (last_dsp.price_date+1), end_date)
              else
                prices = c.get_daily_price_history(symbol, begin_date, end_date)
              end
            end
          else
            prices = c.get_daily_price_history(symbol, NEW_TICKER_BEGIN_DATE, end_date)
          end
          if get_history_returned_error?(prices)
            # TODO Change this so that it handles an exception rather than checks for error condition
            error_count += 1
            puts "Error processing #{symbol} - (attempt ##{error_count}) #{prices.first[:error]}"
            log = log + "Error processing #{symbol} - (attempt ##{error_count}) #{prices.first[:error]}\n"
          else
            error_count = -1
          end
        end

        next if get_history_returned_error?(prices) || prices.first.has_key?(:already_processed)

        of = open(cache_file, "w")
        of.write("ticker_symbol,price_date,open,high,low,close,volume,created_at,updated_at\n")

        price_date_list=Array.new
        prices.each do |bar|
          if price_date_list.index(bar[:timestamp]).nil?
            of.write "#{symbol},#{bar[:timestamp].month}/#{bar[:timestamp].day}/#{bar[:timestamp].year},#{bar[:open]},#{bar[:high]},#{bar[:low]},#{bar[:close]},#{bar[:volume]/10},'#{Time.now}','#{Time.now}'\n"
            price_date_list << bar[:timestamp]
          end
        end
        of.close
      rescue => e
        puts "Error processing #{symbol} - #{e.message}"
        log = log + "Error processing #{symbol} - #{e.message}\n"
        next
      end

      begin
        ActiveRecord::Base.connection.execute(
            "COPY daily_stock_prices (ticker_symbol,price_date,open,high,low,close,volume,created_at,updated_at)
              FROM '#{cache_file}'
              WITH (FORMAT 'csv', HEADER)"
        )

      rescue => e
        puts "#{e.message}"
        log = log + "#{e.message}\n"
      end

    end


    puts log

    puts "Updating Previous Close Cache - #{Time.now}"
    populate_previous_close

    puts "Updating Previous High Cache - #{Time.now}"
    populate_previous_high(Date.today)

    puts "Updating Previous Low Cache - #{Time.now}"
    populate_previous_low(Date.today)

    puts "Updating 52 Week High Cache - #{Time.now}"
    populate_high_52_weeks(Date.today)

    puts "Calculating Average Daily Volumes - #{Time.now}"
    populate_average_volume_50day(NEW_TICKER_BEGIN_DATE)

    puts "Calculating SMA50's - #{Time.now}"
    populate_sma50

    puts "Calculating SMA200's - #{Time.now}"
    populate_sma200

    of = open(log_file, "w")
    of.write(log)
    of.close

    log_problem_tickers=""
    log.lines.each do |line|
      log_problem_tickers+="#{/Error processing (.*?) -/.match(line)[1]}," if /\b#{/Error processing (.*?) -/.match(line)[1]}\b/.match(log_problem_tickers).nil?
    end
    log_problem_tickers.slice!(log_problem_tickers.length-1) if log_problem_tickers.last==","
    puts "Summary report of problem tickers: #{log_problem_tickers}"

  end

  def self.update_daily_stock_prices_from_real_time_snapshot(opts={})
    log_file = File.join(Rails.root, 'downloads', 'import_quotes.log')

    c = TDAmeritradeApi::Client.new
    c.login
    log = ""

    puts "Preparing to update DailyStockPrices - assessing records to be updated"
    records_to_update = DailyStockPrice.where.not(snapshot_time: nil).order(:ticker_symbol, :price_date)
    #records_to_update = DailyStockPrice.where(symbol: 'IDIX', price_date: Date.today).order(:ticker_symbol, :price_date)
    count = records_to_update.count

    price_dates_to_update = records_to_update.map {|dsp| dsp[:price_date] }.uniq

    i = 1
    price_dates_to_update.each do |price_date|
      puts "Updating records from #{price_date}"

      total_count = records_to_update.count
      counter = 1
      records_to_update.select { |dsp| dsp[:price_date]==price_date }.map { |dsp| dsp[:ticker_symbol] }.each_slice(100) do |tickers|
        begin
          quote_bunch=[]
          2.times.each do |error_count|
            begin
              quote_bunch = c.get_price_history(tickers, intervaltype: :daily, intervalduration: 1, startdate: price_date, enddate: price_date)
              break
            rescue Exception => e
              #TODO figure out what causes it - why we trying to get records that dont exist
              puts "Error processing - #{e.message} - attempt (#{error_count + 1})"
              log = log + "Error processing - #{e.message} - attempt (#{error_count + 1})\n"
              sleep Random.rand(15)
            end
          end

          next if quote_bunch.empty?
          quote_bunch.each do |quotes|
            next if quotes[:symbol].nil? || quotes[:bars].nil? || quotes[:bars].length < 1
            ticker_symbol = quotes[:symbol].to_s
            prices = quotes[:bars]

            p = prices.first
            puts "Processing #{counter} of #{total_count}: #{p[:symbol]}"; counter += 1


            if p[:timestamp].to_date != price_date
              puts "Error: price date does not match"
              log = log + "Error processing #{p[:symbol]}: incorrect price date #{p[:timestamp]} vs #{price_date} in the record"
              next
            end
            new_attributes = {
                open: p[:open],
                high: p[:high],
                low: p[:low],
                close: p[:close].to_f.round(2),
                volume: p[:volume]/10,
                previous_close: nil,
                previous_high: nil,
                previous_low: nil,
                average_volume_50day: nil,
                snapshot_time: nil
            }

            dsp = DailyStockPrice.where(ticker_symbol: ticker_symbol, price_date: price_date).first
            if dsp.present?
              dsp.update_attributes(new_attributes)
            end
            i += 1
          end

        end
      end

    end


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

    of = open(log_file, "w")
    of.write(log)
    of.close

    log_problem_tickers=""
    log.lines.each do |line|
      log_problem_tickers+="#{/Error processing (.*?) -/.match(line)[1]}," if /\b#{/Error processing (.*?) -/.match(line)[1]}\b/.match(log_problem_tickers).nil?
    end
    log_problem_tickers.slice!(log_problem_tickers.length-1) if log_problem_tickers.last==","
    puts "Summary report of problem tickers: #{log_problem_tickers}"

  end

  def self.import_realtime_quotes(opts={})
    cache_file =  File.join(Rails.root, 'downloads', "tdameritrade_daily_stock_prices_cache.csv")

    c = TDAmeritradeApi::Client.new
    attempt = 0
    while attempt < 2
      begin
        c.login
        break
      rescue Exception => e
        puts "Error logging in for downloading real time quotes, attempt #{attempt}: #{e.message}"
        attempt += 1
      end
    end

    log = ""

    RealTimeQuote.reset_cache

    ticker_watch_list = Ticker.watching.pluck(:symbol, :id)
    begin
      list = ticker_watch_list.slice!(0,250)
      quotes = nil
      while quotes == nil
        begin
          quotes = c.get_quote(list.map { |x| x[0] })
        rescue
          puts "Error getting quotes - trying again"
        end
      end

      # ticker_id_hash = Hash[list.collect { |i| i }]

      begin
        of = open(cache_file, "w")
        of.write("ticker_symbol,last_trade,quote_time,open,high,low,volume\n")
        quotes.each do |bar|
          if bar[:last].present? && bar[:open].present? && bar[:high].present? && bar[:low].present?
            of.write "#{bar[:symbol]},#{bar[:last]},#{bar[:last_trade_time].to_s},#{bar[:open]},#{bar[:high]},#{bar[:low]},#{bar[:volume]}\n"
          end
        end
        of.close
      rescue
        #puts "Error processing #{bar[:symbol]} - #{e.message}"
        #log = log + "Error processing #{bar[:symbol]} - #{e.message}\n"
        next
      end

      begin
        ActiveRecord::Base.connection.execute(
            "COPY real_time_quotes (ticker_symbol,last_trade,quote_time,open,high,low,volume)
              FROM '#{cache_file}'
              WITH (FORMAT 'csv', HEADER)"
        )
      rescue => e
        puts "#{e.message}"
        log = log + "#{e.message}\n"
      end

    end while list != []

    puts log if log && log != ""
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

    puts "Copying Memoized Premarket Previous Close, High, Low, and Average Daily Volumes - #{Time.now}"
    copy_memoized_fields_to_premarket_prices date

    puts "Updating Premarket Previous Close Cache - #{Time.now}"
    populate_premarket_previous_close date

    puts "Updating Premarket Previous High Cache - #{Time.now}"
    populate_premarket_previous_high date

    puts "Updating Premarket Previous Low Cache - #{Time.now}"
    populate_premarket_previous_low date

    puts "Calculating Premarket Average Daily Volumes - #{Time.now}"
    populate_premarket_average_volume_50day(date)

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

  def self.catch_up(date, vacuum=true)
    unless date.is_a? Date
      puts "Enter an input date"
      return
    end

    prepopulate_daily_stock_prices(date)
    DailyStockPrice.where(price_date: date).update_all(snapshot_time: date)

    update_daily_stock_prices_from_real_time_snapshot
    import_premarket_quotes(date: date)
    import_afterhours_quotes(date: date)

    if vacuum
      ActiveRecord::Base.connection.execute "VACUUM FULL"
      ActiveRecord::Base.connection.execute "VACUUM ANALYZE"
    end
  end

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