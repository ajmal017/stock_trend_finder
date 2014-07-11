def get_history_returned_error?(return_value)
  if return_value.is_a? Array and return_value.length > 0
    return return_value.first.has_key?(:error)
  else
    raise "Error: get_minute_price_history() returned an invalid object"
  end
end

cache_file =  File.join(Rails.root, 'downloads', "tdameritrade_daily_stock_prices_cache.csv")

c = TDAmeritradeApi::Client.new
c.login
log = ""
#c.session_id = "D15DDFBB8EBCC824E2D7FDAD52CC97A8.gAXa98X8axOJ9jeE6m9IqA"


Ticker.watching.where("symbol not like '%^%'").each.with_index(1) do |ticker, i|

  puts "Processing #{i}: #{ticker.symbol}"
  begin
    error_count = 0
    prices = Array.new
    last_msp = MinuteStockPrice.where(ticker_symbol: ticker.symbol).order(price_time: :desc).first

    while error_count < 3 && error_count != -1 # error count should be -1 on a successful download of data
      if last_msp.present?
        if last_msp.price_time > Date.new(2014,05,23)#Date.today
          prices = [{already_processed: true}]
        else
          prices = c.get_minute_price_history(ticker.symbol, begin_date: (last_msp.price_time.to_date+1).strftime('%Y%m%d'))
        end
      else
        prices = c.get_minute_price_history(ticker.symbol, begin_date: '20140512')
      end
      if get_history_returned_error?(prices)
        error_count += 1
        puts "Error processing #{ticker.symbol} - (attempt ##{error_count}) #{prices.first[:error]}"
        log = log + "Error processing #{ticker.symbol} - (attempt ##{error_count}) #{prices.first[:error]}\n"
      else
        error_count = -1
      end
    end

    next if get_history_returned_error?(prices) || prices.first.has_key?(:already_processed)

    of = open(cache_file, "w")
    of.write("ticker_id,ticker_symbol,price_time,open,high,low,close,volume,created_at,updated_at\n")
    prices.each do |bar|
      of.write "#{ticker.id},#{ticker.symbol},#{bar[:timestamp].strftime("%D %T%z")},#{bar[:open]},#{bar[:high]},#{bar[:low]},#{bar[:close]},#{bar[:volume]/10},'#{Time.now}','#{Time.now}\n"
    end
    of.close

  rescue => e
    puts "Error processing #{ticker.symbol} - #{e.message}"
    log = log + "Error processing #{ticker.symbol} - #{e.message}\n"
    next
  end

  begin
    ActiveRecord::Base.connection.execute(
        "COPY minute_stock_prices (ticker_id,ticker_symbol,price_time,open,high,low,close,volume,created_at,updated_at)
              FROM '#{cache_file}'
              WITH (FORMAT 'csv', HEADER)"
    )
  rescue => e
    puts "#{e.message}"
    log = log + "#{e.message}\n"
  end

end


puts log


log_problem_tickers=""
log.lines.each do |line|
  log_problem_tickers+="#{/Error processing (.*?) -/.match(line)[1]}," if /\b#{/Error processing (.*?) -/.match(line)[1]}\b/.match(log_problem_tickers).nil?
end
log_problem_tickers.slice!(log_problem_tickers.length-1) if log_problem_tickers.last==","
puts "Summary report of problem tickers: #{log_problem_tickers}"


