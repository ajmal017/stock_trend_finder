require 'open-uri'

[:nyse, :nasdaq, :amex].each do |exchange|
  puts "Processing #{exchange.capitalize} ticker list from ThinkOrSwim list..."

  # download file
  ticker_list_tmpfile = File.join(Rails.root, 'downloads', "toslist-#{exchange}.csv")

  # parse fields and for each ticker, check to see if its in the database. if not, then add it
  f = open(ticker_list_tmpfile)
  f.each_line.map do |line|
    symbol=line.scan(/(.*?),.*?/)[0][0]
    symbol = symbol.strip
    next if symbol=="Symbol" #skip the header
    next if !symbol.scan(/\/|\./)[0].nil?
    t=Ticker.find_by(symbol: symbol)
    if t.nil?
      puts "Adding new ticker #{symbol}"
      Ticker.create(symbol: symbol, exchange: exchange.to_s,scrape_data: true)
    end
  end
  f.close
end
