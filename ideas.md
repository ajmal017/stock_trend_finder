### TODOs

* Tickers: 
  - Track addition/changes of tickers
  - Page for each ticker with info about it
    - any data changes to cusip or title
* Dividend yield scanner
* Chart of number of companies reaching 52 wk high/low

### Ideas for new features

* Report to help filter out defunct tickers
* Handle splits!


Stock Data
* Reset stock history after split - this includes making volume history adjustments
* "as recorded" daily stock price table - populate it with stock data upon resetting. only daily stock prices 
  get reset - premarket prices remain
* On gaps report, click the symbol to find the stock's gap history
  - Previous high
  - Previous close
  - % gap
  - Volume
  - Volume average
  - Movement over 3 days, 5 days, 10 days, 20 days
* Dividend  


VIX
    - Download the historical VIX futures data from CBOT and put it into the database
        - Determine length of historical bouts of contango and anticipated effects on XIV


Reports
    - Winners over date range period of time
        * Currently above or below 200DMA?
        * Graph of stocks above/below 50DMA over time
        * Sector/Category tags?
        * Order by tag
    - Earnings report
        * Have a "not interested" action
    - Bond yield curve that mimics VIX Futures curve functionality
    - Dividend leaders
    - Number of stocks above/below 200DMA (need split function for this to work effectively)
    - Stocks that hit a 52wk high within the last 2 weeks. Number & list.
    - 52-wk high list
    - Sectors that are up or down by the last X number of days
      - market cap
      - country (Chinese stocks, American stocks, etc)
      - custom groups - video game stocks, certain types of x or y stocks
    - Way to hide stocks I don't want to see on each report - report - hide_until date
    -  

    
Stocktwits Report

* Download system refactor ideas
    - PrepopulateDatabase module
        - Populate moving average fields
        - Populate yesterday HLC 
    - ExternalMarketData module
        - \#import_daily_quotes(date)
        - TDAmeritradeInterface

Ticker List
    - Show 12-mo dividend yield
    - Allow it to replace the tickers Excel sheet
    - Tags with each ticker
    
    
    
    Good stuff:
sims = DailyStockPrice.where.not(snapshot_time: nil).pluck(:ticker_symbol).uniq  # gets all problematic tickers
quotes = c.get_quote(sims)
qm = quotes.map { |q| [q[:symbol], q[:description], q[:error]] }
filter_invalid = qm.select { |qm| qm[2] =~ /Invalid/ }
filter_not_found = qm.select { |qm| qm[1] =~ /not found/ }
filter_no_name = qm.select { |qm| qm[1].length==0 }
filter_acquisition_unit = qm.select { |qm| qm[0] =~ /....U/ } 
(filter_invalid + filter_not_found + filter_no_name).each { |f| Ticker.unscrape f[0] }

sims.each do |symbol|
   puts "Unscrape #{symbol}?"
   r = gets
   if r.index('y')
     Ticker.unscrape symbol
     puts "Removing #{symbol}"
   end  
end  
            
