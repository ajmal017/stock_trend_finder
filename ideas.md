### Ideas for new features

* Dividend yield scanner
* Report to help filter out defunct tickers
* Build FIX API for CTCI link to IB (new data provider)
* Create a "flags" list for ticker analysis - basically the Tickers tab on my spreadsheet but interface thru this app. Suggested labels:
    - barrons-positive
    - fundamental-favorite
    - sector-specific tags, i.e. China, oil, cloud
* Add reason tag to tickers table with unscrape_reason: acquisition, liquidity, delist

VIX
    - Download the historical VIX futures data from CBOT and put it into the database
        - Determine length of historical bouts of contango and anticipated effects on XIV


Reports
    - Winners over date range period of time
        * Currently above or below 200DMA?
        * Graph of stocks above/below 50DMA over time
        * Sector/Category tags?
        * Order by tag
    - Refactor report column builder

    
Stocktwits Report
    - Add comments field for twits

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
            
