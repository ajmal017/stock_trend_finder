require 'tdameritrade_data_interface/sql_query_strings'

module TDAmeritradeDataInterface
  NEW_TICKER_BEGIN_DATE=Date.new(2012,01,02)

  include SQLQueryStrings

  def self.import_quotes(opts={})
    begin_date = (opts.has_key? :begin_date) && (opts[:begin_date].is_a? Date) ? opts[:begin_date] : nil
    end_date = (opts.has_key? :end_date) && (opts[:end_date].is_a? Date) ? opts[:end_date].strftime('%Y%m%d') : Date.today.strftime('%Y%m%d')

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
            if last_dsp.price_date == begin_date
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


    puts "Calculating Average Daily Volumes"
    populate_average_volume_50day(NEW_TICKER_BEGIN_DATE)

    puts "Calculating EMA13's"
    populate_ema13(NEW_TICKER_BEGIN_DATE)

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
    c.login
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

    puts log
  end


  def self.populate_average_volume_50day(begin_date=Date.today)
    ActiveRecord::Base.connection.execute update_average_volume_50day(begin_date)
  end

  def self.populate_ema13(begin_date=Date.new(2012,01,02))

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

  private
  def self.get_history_returned_error?(return_value)
    if return_value.is_a? Array and return_value.length > 0
      return return_value.first.has_key?(:error)
    else
      raise "Error: get_daily_price_history() returned an invalid object"
    end
  end

end