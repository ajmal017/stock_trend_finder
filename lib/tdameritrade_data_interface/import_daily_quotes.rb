require 'tdameritrade_data_interface/sql_query_strings'
require 'tdameritrade_data_interface/util'

module TDAmeritradeDataInterface
  NEW_TICKER_BEGIN_DATE=Date.new(2013,10,1)

  include SQLQueryStrings

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

    Ticker.watching.where("symbol not like '%^%'").each.with_index(1) do |ticker, i|
      #Ticker.watching.where("symbol='AAOI'").each.with_index(1) do |ticker, i|

      puts "Processing #{i}: #{ticker.symbol}"
      begin
        error_count = 0
        prices = Array.new
        last_dsp = DailyStockPrice.where(ticker_symbol: ticker.symbol).order(price_date: :desc).first

        while error_count < 3 && error_count != -1 # error count should be -1 on a successful download of data
          if last_dsp.present?
            if last_dsp.price_date == end_date
              prices = [{already_processed: true}]
            else
              if begin_date.nil?
                prices = c.get_daily_price_history(ticker.symbol, (last_dsp.price_date+1), end_date)
                #prices = c.get_daily_price_history(ticker.symbol, Date.today.strftime('%Y%m%d'))
                #prices = c.get_daily_price_history(ticker.symbol, '20140708')
              else
                prices = c.get_daily_price_history(ticker.symbol, begin_date, end_date)
              end
            end
          else
            prices = c.get_daily_price_history(ticker.symbol, NEW_TICKER_BEGIN_DATE, end_date)
          end
          if get_history_returned_error?(prices)
            # TODO Change this so that it handles an exception rather than checks for error condition
            error_count += 1
            puts "Error processing #{ticker.symbol} - (attempt ##{error_count}) #{prices.first[:error]}"
            log = log + "Error processing #{ticker.symbol} - (attempt ##{error_count}) #{prices.first[:error]}\n"
          else
            error_count = -1
          end
        end

        next if get_history_returned_error?(prices) || prices.first.has_key?(:already_processed)

        of = open(cache_file, "w")
        of.write("ticker_id,ticker_symbol,price_date,open,high,low,close,volume,created_at,updated_at\n")

        price_date_list=Array.new
        prices.each do |bar|
          if price_date_list.index(bar[:timestamp]).nil?
            of.write "#{ticker.id},#{ticker.symbol},#{bar[:timestamp].month}/#{bar[:timestamp].day}/#{bar[:timestamp].year},#{bar[:open]},#{bar[:high]},#{bar[:low]},#{bar[:close]},#{bar[:volume]/10},'#{Time.now}','#{Time.now}'\n"
            price_date_list << bar[:timestamp]
          end
        end
        of.close
      rescue => e
        puts "Error processing #{ticker.symbol} - #{e.message}"
        log = log + "Error processing #{ticker.symbol} - #{e.message}\n"
        next
      end

      begin
        ActiveRecord::Base.connection.execute(
            "COPY daily_stock_prices (ticker_id,ticker_symbol,price_date,open,high,low,close,volume,created_at,updated_at)
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

    puts "Calculating Average Daily Volumes - #{Time.now}"
    populate_average_volume_50day(NEW_TICKER_BEGIN_DATE)

    #puts "Calculating EMA13's"
    #populate_ema13

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
          3.times.each do |error_count|
            begin
              quote_bunch = c.get_price_history(tickers, intervaltype: :daily, intervalduration: 1, startdate: price_date, enddate: price_date)
              break
            rescue Exception => e
              #binding.pry
              puts "Error processing - #{e.message} - attempt (#{error_count + 1})"
              log = log + "Error processing - #{e.message} - attempt (#{error_count + 1})\n"
              sleep 10
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
                ema13: nil,
                candle_vs_ema13: nil,
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

    #puts "Calculating EMA13's"
    #populate_ema13

    puts "Updating Previous High Cache - #{Time.now}"
    populate_previous_high

    puts "Updating Previous Low Cache - #{Time.now}"
    populate_previous_low

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
        puts "Error downloading real time quotes, attempt #{attempt}: #{e.message}"
        attempt += 1
      end
    end

    log = ""
    #c.session_id = "128459556EEA989391FBAAA5E2BF8EB4.cOr5v8xckaAXQxWmG7bn2g"

    RealTimeQuote.reset_cache

    ticker_watch_list = Ticker.watching.where("symbol not like '%^%'").pluck(:symbol, :id)
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

      ticker_id_hash = Hash[list.collect { |i| i }]

      begin
        of = open(cache_file, "w")
        of.write("ticker_id,ticker_symbol,last_trade,quote_time,open,high,low,volume\n")
        quotes.each do |bar|
          if bar[:last].present? && bar[:open].present? && bar[:high].present? && bar[:low].present?
            of.write "#{ticker_id_hash[bar[:symbol]]},#{bar[:symbol]},#{bar[:last]},#{bar[:last_trade_time].to_s},#{bar[:open]},#{bar[:high]},#{bar[:low]},#{bar[:volume]}\n"
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
            "COPY real_time_quotes (ticker_id,ticker_symbol,last_trade,quote_time,open,high,low,volume)
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
    DailyStockPrice.transaction do
      if is_market_day?(prepopulate_date)
        puts "Prepopulating Previous Close, Previous High, Previous Low - #{Time.now}"
        ActiveRecord::Base.connection.execute insert_daily_stock_prices_prepopulated_fields(prepopulate_date)

        puts "Calculating Average Daily Volumes - #{Time.now}"
        populate_average_volume_50day(Date.today)

        puts "Done - #{Time.now}"
      else
        puts "Market closed today, no prepopulation necessary"
      end
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
      puts "Invalid date submitted to import_premarket quotes"
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
          prices = quotes[:bars].select { |bar| bar[:timestamp] > Time.parse(bar[:timestamp].strftime('%a, %d %b %Y 16:10:00')) }

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

  def self.catch_up(date)
    unless date.is_a? Date
      puts "Enter an input date"
      return
    end

    prepopulate_daily_stock_prices(date)

    update_daily_stock_prices_from_real_time_snapshot
    import_premarket_quotes(date: date)
    import_afterhours_quotes(date: date)
    VIXFuturesHistory.import_vix_futures(true)
    Stocktwit.sync_twits

    ActiveRecord::Base.connection.execute "VACUUM FULL"
    ActiveRecord::Base.connection.execute "VACUUM ANALYZE"
  end

  def self.realtime_quote_daemon_block
    puts "Real Time Quote Import: #{Time.now}"
    if is_market_day? Date.today
      ActiveRecord::Base.connection_pool.with_connection do
        import_realtime_quotes
        copy_realtime_quotes_to_daily_stock_prices
      end
      puts "Done #{Time.now}\n\n"
    else
      puts "Market closed today, no real time quote download necessary"
    end
  end

  def self.run_realtime_quotes_daemon
    scheduler = Rufus::Scheduler.new
    scheduler.cron('15,45 10-15 * * MON-FRI') { realtime_quote_daemon_block }
    scheduler2 = Rufus::Scheduler.new
    scheduler2.cron('45 9 * * MON-FRI') { realtime_quote_daemon_block }
    puts "#{Time.now} Beginning realtime quote import daemon..."
    [scheduler, scheduler2]
  end

  def self.run_daily_quotes_daemon
    scheduler = Rufus::Scheduler.new
    scheduler.cron('10 16 * * MON-FRI') do
      puts "Daily Quote Import: #{Time.now}"
      if is_market_day? Date.today
        ActiveRecord::Base.connection_pool.with_connection do
          update_daily_stock_prices_from_real_time_snapshot
        end
      else
        puts "Market closed today, no real time quote download necessary"
      end
    end
    puts "#{Time.now} Beginning daily quotes update daemon..."
    scheduler
  end

  def self.run_prepopulate_daily_stock_quotes_daemon
    scheduler = Rufus::Scheduler.new
    scheduler.cron('12 6 * * MON-FRI') do
      puts "Prepopulating daily_stock_quotes table: #{Time.now}"
      ActiveRecord::Base.connection_pool.with_connection do
        prepopulate_daily_stock_prices(Date.today)
      end
    end
    puts "#{Time.now} Beginning daily_stock_prices prepopulate daemon..."
    scheduler
  end

  def self.run_premarket_quotes_daemon
    scheduler = Rufus::Scheduler.new
    scheduler.cron('9,28,40,59 8 * * MON-FRI') do
      puts "Premarket Quote Import: #{Time.now}"
      if is_market_day? Date.today
        ActiveRecord::Base.connection_pool.with_connection do
          import_premarket_quotes(date: Date.today)
        end
      else
        puts "Market closed today, no real time quote download necessary"
      end
    end
    puts "#{Time.now} Beginning premarket quotes update daemon..."
    scheduler
  end

  def self.run_afterhours_quotes_daemon
    scheduler = Rufus::Scheduler.new
    scheduler.cron('0 17,18,19,21 * * MON-FRI') do
      puts "Afterhours Quote Import: #{Time.now}"
      if is_market_day? Date.today
        ActiveRecord::Base.connection_pool.with_connection do
          import_afterhours_quotes(date: Date.today)
        end
      else
        puts "Market closed today, no real time quote download necessary"
      end
    end
    puts "#{Time.now} Beginning afterhours quotes update daemon..."
    scheduler
  end

  def self.run_stocktwits_sync_daemon
    scheduler = Rufus::Scheduler.new
    scheduler.cron('0 0,7,16 * * *') do
      puts "StockTwits data sync: #{Time.now}"
      ActiveRecord::Base.connection_pool.with_connection do
        Stocktwit.sync_twits
      end
    end
    puts "#{Time.now} Beginning StockTwits sync daemon..."
    scheduler
  end

  def self.run_import_vix_futures_daemon
    scheduler = Rufus::Scheduler.new
    scheduler.cron('0 9,10,14,17 * * MON-FRI') do
      puts "VIX Futures data sync: #{Time.now}"
      ActiveRecord::Base.connection_pool.with_connection do
        VIXFuturesHistory.import_vix_futures if is_market_day?(Date.today)
      end
      puts "Done"
    end
    puts "#{Time.now} Beginning VIX Futures History daemon..."
    scheduler
  end

  def self.run_db_maintenance_daemon
    scheduler = Rufus::Scheduler.new
    scheduler.cron('0 1 * * SUN-FRI') do
      puts "Running DB VACUUM: #{Time.now}"
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.connection.execute "VACUUM FULL"
        ActiveRecord::Base.connection.execute "VACUUM ANALYZE"
      end
      puts "Done"
    end

    scheduler_rts = Rufus::Scheduler.new
    scheduler_rts.cron('0 1 * * SAT') do
      puts "Resetting Realtime Snapshot Flags #{Time.now}"
      ActiveRecord::Base.connection_pool.with_connection do
        $stf.reset_snapshot_flags
      end
      puts "Done"
    end
    puts "#{Time.now} Beginning DB Maintenance daemon..."
    scheduler
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

  def self.populate_ema13(begin_date=Date.new(2014,05,02))

    begin
      # Populate the first entry - sma13
      ActiveRecord::Base.connection.execute update_ema13_first_sma(begin_date)

      # Populate the remaining items
      (begin_date..Date.today).each do |d|
        puts "Populating EMA13 for #{d}"
        ActiveRecord::Base.connection.execute(update_ema13(d))
      end

      ActiveRecord::Base.connection.execute update_candle_vs_ema13

    rescue => e
      puts "#{e.message}"
      log = log + "#{e.message}\n"
    end

  end

  def self.populate_sma50

    begin
      # Populate the first entry - sma13
      ActiveRecord::Base.connection.execute update_sma50

    rescue => e
      puts "#{e.message}"
      log = log + "#{e.message}\n"
    end

  end

  def self.populate_sma200

    begin
      # Populate the first entry - sma13
      ActiveRecord::Base.connection.execute update_sma200

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
      ActiveRecord::Base.connection.execute insert_daily_stock_prices_from_realtime_quotes
      ActiveRecord::Base.connection.execute update_daily_stock_prices_from_realtime_quotes

      puts "Updating Previous Close Cache - #{Time.now}"
      populate_previous_close(Date.today)

      puts "Updating Previous High Cache - #{Time.now}"
      populate_previous_high(Date.today)

      puts "Updating Previous Low Cache - #{Time.now}"
      populate_previous_low(Date.today)

      puts "Calculating Average Daily Volumes - #{Time.now}"
      populate_average_volume_50day(Date.today)

      #puts "Calculating EMA13's"
      #populate_ema13(Date.today)

      puts "Calculating SMA50's - #{Time.now}"
      populate_sma50

      puts "Calculating SMA200's - #{Time.now}"
      populate_sma200

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