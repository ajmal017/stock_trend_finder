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
    - Rearrange scanner report so its easier to read
    - Use YAHOO API to get float

    
Stocktwits Report
    - Add comments field for twits

* Download system refactor ideas
    - PrepopulateDatabase module
        - Populate moving average fields
        - Populate yesterday HLC 
    - ExternalMarketData module
        - \#import_daily_quotes(date)
        - TDAmeritradeInterface
            
        - YahooInterface
            - VIXFutures
            
