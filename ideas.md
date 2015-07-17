### Ideas for new features

* Dividend yield scanner
* Report to help filter out defunct tickers
* Build FIX API for CTCI link to IB (new data provider)
* Create a "flags" list for ticker analysis - basically the Tickers tab on my spreadsheet but interface thru this app. Suggested labels:
    - barrons-positive
    - fundamental-favorite
    - sector-specific tags, i.e. China, oil, cloud
* VIX report
    - days to next expiration
    - estimated % VIX1, %VIX2
    - rollyield
    - contango roll
    
* Download system refactor ideas
    - PrepopulateDatabase module
        - Populate moving average fields
        - Populate yesterday HLC 
    - ExternalMarketData module
        - \#import_daily_quotes(date)
        - TDAmeritradeInterface
            
        - YahooInterface
            - VIXFutures