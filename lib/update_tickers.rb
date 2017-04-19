require 'open-uri'

NYSE_TICKER_LIST_URL="http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download"
NASDAQ_TICKER_LIST_URL="http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download"
AMEX_TICKER_LIST_URL="http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download"

[:nyse, :nasdaq, :amex].each do |exchange|
  puts "Processing #{exchange.capitalize} ticker list..."

  # download file
  ticker_list_url = Kernel.const_get "#{exchange.to_s.upcase}_TICKER_LIST_URL"
  ticker_list_tmpfile = File.join(Rails.root, 'downloads', "#{exchange}_ticker_list.csv")

  f = open(ticker_list_tmpfile, "w")
  f.write(open(ticker_list_url).read)
  f.close

  # parse fields and for each ticker, check to see if its in the database. if not, then add it
  f = open(ticker_list_tmpfile)
  f.each_line.map do |line|
    symbol,company_name,last_sale,market_cap,adr_tso,ipo_year,sector,industry,summary_quote=line.scan(/"(.*?)","(.*?)","(.*?)","(.*?)","(.*?)","(.*?)","(.*?)","(.*?)","(.*?)",/)[0]
    symbol = symbol.strip
    company_name = company_name.strip
    next if symbol=="Symbol" #skip the header
    next if symbol.match(/\^/) != nil
    next if sector=='n/a' #on this list, items with a 'n/a' are usually funds or ETFs
    t=Ticker.find_by(symbol: symbol)
    if t.nil?
      puts "Adding new ticker #{symbol}"
      Ticker.create(symbol: symbol, company_name: company_name, exchange: exchange.to_s, sector: sector, industry: industry, market_cap: market_cap, scrape_data: true)
    else
      t.market_cap = market_cap
      t.save!
    end
  end
  f.close

  # i removed the following function because sometimes the list could be faulty
  # get a list of the tickers not on the list and flag them as date_removed
  #Ticker.where(exchange: exchange.to_s).each do |ticker|
  #  if updated_symbol_list.index(ticker.symbol).nil?
  #    puts "Removing ticker #{ticker.symbol} #{ticker.company_name}"
  #    ticker.date_removed = Date.today
  #    ticker.save!
  #  end
  #end

end
