module TDAmeritradeDataInterface

  def self.populate_true_range_5min
    # took 12838751 ms execution time.
    <<SQL
update stock_prices5_minutes sp
set true_range=(
greatest(
high-low,
high-(select close from stock_prices5_minutes sp_last where sp_last.ticker_symbol=sp.ticker_symbol and sp_last.price_time<sp.price_time order by price_time desc limit 1),
(select close from stock_prices5_minutes sp_last where sp_last.ticker_symbol=sp.ticker_symbol and sp_last.price_time<sp.price_time order by price_time desc limit 1)-low
)
)
SQL
  end

  def self.populate_true_range_percent_5min
    <<SQL
update stock_prices5_minutes sp
set true_range_percent=round(true_range / (select close from stock_prices5_minutes sp_last where sp_last.ticker_symbol=sp.ticker_symbol and sp_last.price_time<sp.price_time order by price_time desc limit 1), 5)
where true_range is not null
SQL
  end

  def self.populate_true_range_15min
    # takes about 807543 ms execution time.
  <<SQL
update stock_prices15_minutes sp
set true_range=(
greatest(
high-low,
high-(select close from stock_prices15_minutes sp_last where sp_last.ticker_symbol=sp.ticker_symbol and sp_last.price_time<sp.price_time order by price_time desc limit 1),
(select close from stock_prices15_minutes sp_last where sp_last.ticker_symbol=sp.ticker_symbol and sp_last.price_time<sp.price_time order by price_time desc limit 1)-low
)
)
SQL
  end

  def self.populate_true_range_percent_15min
    # takes about 604395 ms execution time
    <<SQL
update stock_prices15_minutes sp
set true_range_percent=round(true_range / (select close from stock_prices15_minutes sp_last where sp_last.ticker_symbol=sp.ticker_symbol and sp_last.price_time<sp.price_time order by price_time desc limit 1), 5)
where true_range is not null
SQL
  end

  def populate_average_true_range_15min
    <<SQL
SQL
  end

  def self.import_5min_history(opts={})
    cache_file =  File.join(Rails.root, 'downloads', "tdameritrade_daily_stock_prices_cache.csv")
    log_file = File.join(Rails.root, 'downloads', 'import_quotes.log')

    c = TDAmeritradeApi::Client.new
    c.login
    log = ""

    StockPrices5Minute.reset

    Ticker.watching.where("symbol not like '%^%'").each.with_index(1) do |ticker, i|
      #Ticker.watching.where("symbol='AAOI'").each.with_index(1) do |ticker, i|

      puts "Processing #{i}: #{ticker.symbol}"
      begin
        next if StockPrices5Minute.where(ticker_symbol: ticker.symbol).present?

        prices = Array.new
        attempts_remaining = 3
        while attempts_remaining > 0
          begin
            attempts_remaining -= 1
            prices = c.get_price_history(ticker.symbol, intervaltype: :minute, intervalduration: 5, periodtype: :day, period: 10, extended:true).first[:bars]
          rescue => e
            puts "Error processing #{ticker.symbol} (attempt ##{3-attempts_remaining}) - #{e.message}"
            log = log + "Error processing #{ticker.symbol} - (attempt ##{3-attempts_remaining}) - #{e.message}\n"
            return if e.is_a? Interrupt
            next
          end
          attempts_remaining = 0 # made it past the rescue block, so no error
        end

        raise RuntimeError.new("get_price_history() returned an invalid object") if !prices.is_a?(Array) || prices.count < 1

        of = open(cache_file, "w")
        of.write("ticker_id,ticker_symbol,price_time,open,high,low,close,volume,created_at,updated_at\n")

        price_date_list=Array.new
        prices.each do |bar|
          if price_date_list.index(bar[:timestamp]).nil?
            of.write "#{ticker.id},#{ticker.symbol},#{bar[:timestamp].to_s},#{bar[:open]},#{bar[:high]},#{bar[:low]},#{bar[:close]},#{bar[:volume]/10},'#{Time.now}','#{Time.now}'\n"
            price_date_list << bar[:timestamp]
          end
        end
        of.close
      rescue => e
        puts "Error processing #{ticker.symbol} - #{e.message}"
        log = log + "Error processing #{ticker.symbol} - #{e.message}\n"
        return if e.is_a? Interrupt
        next
      end

      begin
        ActiveRecord::Base.connection.execute(
            "COPY stock_prices5_minutes (ticker_id,ticker_symbol,price_time,open,high,low,close,volume,created_at,updated_at)
              FROM '#{cache_file}'
              WITH (FORMAT 'csv', HEADER)"
        )

      rescue => e
        puts "#{e.message}"
        log = log + "#{e.message}\n"
        return if e.is_a? Interrupt
      end

    end


    ActiveRecord::Base.connection.execute populate_true_range_5min
    ActiveRecord::Base.connection.execute populate_true_range_percent_5min

    puts log
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

  def self.import_15min_history(opts={})
    cache_file =  File.join(Rails.root, 'downloads', "tdameritrade_daily_stock_prices_cache.csv")
    log_file = File.join(Rails.root, 'downloads', 'import_quotes.log')

    c = TDAmeritradeApi::Client.new
    c.login
    log = ""

    StockPrices15Minute.reset

    Ticker.watching.where("symbol not like '%^%'").each.with_index(1) do |ticker, i|
      #Ticker.watching.where("symbol='AAOI'").each.with_index(1) do |ticker, i|

      puts "Processing #{i}: #{ticker.symbol}"
      begin
        next if StockPrices15Minute.where(ticker_symbol: ticker.symbol).present?

        prices = Array.new
        attempts_remaining = 3
        while attempts_remaining > 0
          begin
            attempts_remaining -= 1
            prices = c.get_price_history(ticker.symbol, intervaltype: :minute, intervalduration: 15, periodtype: :day, period: 10, extended: true).first[:bars]
          rescue => e
            puts "Error processing #{ticker.symbol} (attempt ##{3-attempts_remaining}) - #{e.message}"
            log = log + "Error processing #{ticker.symbol} - (attempt ##{3-attempts_remaining}) - #{e.message}\n"
            return if e.is_a? Interrupt
            next
          end
          attempts_remaining = 0 # made it past the rescue block, so no error
        end

        raise RuntimeError.new("get_price_history() returned an invalid object") if !prices.is_a?(Array) || prices.count < 1

        of = open(cache_file, "w")
        of.write("ticker_id,ticker_symbol,price_time,open,high,low,close,volume,created_at,updated_at\n")

        price_date_list=Array.new
        prices.each do |bar|
          if price_date_list.index(bar[:timestamp]).nil?
            of.write "#{ticker.id},#{ticker.symbol},#{bar[:timestamp].to_s},#{bar[:open]},#{bar[:high]},#{bar[:low]},#{bar[:close]},#{bar[:volume]/10},'#{Time.now}','#{Time.now}'\n"
            price_date_list << bar[:timestamp]
          end
        end
        of.close
      rescue => e
        puts "Error processing #{ticker.symbol} - #{e.message}"
        log = log + "Error processing #{ticker.symbol} - #{e.message}\n"
        return if e.is_a? Interrupt
        next
      end

      begin
        ActiveRecord::Base.connection.execute(
            "COPY stock_prices15_minutes (ticker_id,ticker_symbol,price_time,open,high,low,close,volume,created_at,updated_at)
              FROM '#{cache_file}'
              WITH (FORMAT 'csv', HEADER)"
        )

      rescue => e
        puts "#{e.message}"
        log = log + "#{e.message}\n"
        return if e.is_a? Interrupt
      end

    end

    puts log
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


end