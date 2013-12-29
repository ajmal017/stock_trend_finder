require 'open-uri'

Ticker.watching.where("symbol not like '%^%'").each do |ticker|
  puts "Processing #{ticker.symbol}..."

  download_file_path = File.join(Rails.root, 'downloads', "#{ticker.symbol}_prices_googlefinance.csv".sub('^', 'v'))
  db_read_file_path = File.join(Rails.root, 'downloads', 'imports', "#{ticker.symbol}_prices_googlefinance_dbimport.csv".sub('^', 'v'))
  #most_recent_price = ticker.daily_stock_prices.count > 0 ? ticker.daily_stock_prices.last.price_date : nil
  #
  ## Download data from Yahoo! and
  #download_file_url =  "http://ichart.finance.yahoo.com/table.csv?s=#{ticker.symbol.sub('^', '%5E')}&d=#{Date.today.month-1}&e=#{Date.today.day}&f=#{Date.today.year}&g=d&ignore=.csv"
  #puts "Downloading quotes to #{download_file_path} from #{download_file_url}"
  #download_file = open(download_file_path, 'w')
  #download_file.write(open(
  #                        download_file_url
  #                    ).read)
  #download_file.close
  #
  # Reopen the raw CSV file and reformat it for use with the COPY command for Postgresql
  if File.exists? download_file_path
    download_file = open(download_file_path)
    download_file_lines = download_file.readlines
    download_file.close

    db_read_file = open(db_read_file_path, 'w')

    # Put the column headers on the first line
    db_read_file.write("ticker_id,price_date,open,high,low,close,volume\n")
    #Remove the Google header from the input file
    download_file_lines.shift if download_file_lines[0].match(/Date/).length > 0

    puts "Reformatting data in  #{db_read_file_path}"
    while download_file_lines.count > 0
      price_date,open,high,low,close,volume=download_file_lines.pop.split(',')
      db_read_file.write("#{ticker.id},#{price_date},#{open.sub('-', '')},#{high.sub('-', '')},#{low.sub('-', '')},#{close.sub('-', '')},#{volume.sub('-', '')}")
    end

    #db_read_file.close

    #ActiveRecord::Base.establish_connection(...)
    #ActiveRecord::Base.connection().execute(...)

      ActiveRecord::Base.connection.execute(
          "COPY daily_stock_prices (ticker_id,price_date,open,high,low,close,volume)
              FROM '#{db_read_file_path}'
              WITH (FORMAT 'csv', HEADER)"
      ) if DailyStockPrice.find_by(ticker_id: ticker.id).nil? && File.exists?(db_read_file_path)
  end

  # Now need to run update statements to set open, high,low,close=null where the values are 0.


end
