require 'open-uri'

Ticker.watching.where("symbol not like '%^%'").each do |ticker|
  puts "Processing #{ticker.symbol}..."

  download_file_path = File.join(Rails.root, 'downloads', "#{ticker.symbol}_prices_yahoofinance.csv".sub('^', 'v'))
  db_read_file_path = File.join(Rails.root, 'downloads', 'imports', "#{ticker.symbol}_prices_yahoofinance_dbimport.csv".sub('^', 'v'))
  if File.exists? download_file_path
    download_file = open(download_file_path)
    download_file_lines = download_file.readlines
    download_file.close

    next if download_file_lines.length == 0

    db_read_file = open(db_read_file_path, 'w')

    # Put the column headers on the first line
    db_read_file.write("ticker_id,ticker_symbol,price_date,open,high,low,close,volume\n")
    #Remove the header from the input file
    download_file_lines.shift if download_file_lines[0].match(/Date/).length > 0

    puts "Reformatting data in  #{db_read_file_path}"
    while download_file_lines.count > 0
      price_date,open,high,low,close,volume,adj_close=download_file_lines.pop.split(',')
      db_read_file.write("#{ticker.id},#{ticker.symbol},#{price_date},#{open.sub('-', '')},#{high.sub('-', '')},#{low.sub('-', '')},#{close.sub('-', '')},#{volume.sub('-', '')}\n")
    end

      ActiveRecord::Base.connection.execute(
          "COPY daily_stock_prices (ticker_id,ticker_symbol,price_date,open,high,low,close,volume)
              FROM '#{db_read_file_path}'
              WITH (FORMAT 'csv', HEADER)"
      ) if DailyStockPrice.find_by(ticker_id: ticker.id).nil? && File.exists?(db_read_file_path)
  end

  # Now need to run update statements to set open, high,low,close=null where the values are 0.


end
