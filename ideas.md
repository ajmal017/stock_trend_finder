### TODOs

* Short term goals
  - Daily report review checkoff report (don't leave any stones unturned)
  - Consolidated summary report (actions lead to partial checkoff report)
  - Reports and unreviewed items
  - Log trades and pair to opening trades
  - Favorite items on report for each day, see recent favorites report
  - Detect nosedive setup, 200DMA pullback, 200DMA breakout
  - Discord integration
    * Precursor is cropping of charts option  



* 52 week report
  - ~~Streak -> number of days on report within the last 100 trading days~~
  - ~~Note IPO date, or days since IPO~~                                   

* 52 week report in charts:
  - ~~Chart of number of companies reaching 52 wk high/low~~
  - Chart of number of scrapable stocks
  - Breakdown by sector

* Tickers: 
  - ~~Page for each ticker with info about it~~
    - ~~any data changes to cusip or title~~

* Stocktwits:
  - Timer tickers - reminder to look at a stock after a certain amount of time
  - Split into its own app
  - Conslidate hashtags
    - have hierarchial - supercategory groupings
  - Gold nugget indicator for gold stocks/silver
  - ~~Capture note with delay for when doing one screen~~
  - ~~Edit the Twits~~

  - ~~Fix Institutional Ownership~~
  - Refactor cron jobs
  - Have stocktwits notes appear in a discord


* Big volume - within 95% of 52 week high and 3X normal volume 
* yields report
* 10% down
* Dividend yield scanner
  - Utilities
  - REITS
* SPY top 20 winners and losers
* Scrape 13Fs from SEC website (EDGAR project)
* 200DMA break - turning point (gets above the 200 and curvature shifts) - RDUS, NVDA
* Highlight stocks of interest on the scans
* Research engulfing candles
* favorite items on each report
* track days that I've looked at or missed
* add market cap to other reports

* Options open interest
  - Chart of SPY open interest, next 5 or so weekly expirations and open interest at strikes

* ~~Add market cap to reports~~
* ~~Filter for price cutoff and or market cap~~

### Stuff to ask TDA

How to identify debt securities? LTSH, SOLN


### Ideas for new features



Stock Data
* Handle splits!
* Reset stock history after split - this includes making volume history adjustments
* "as recorded" daily stock price table - populate it with stock data upon resetting. only daily stock prices 
  get reset - premarket prices remain


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
    - ExternalMarketData module
        - \#import_daily_quotes(date)
        - TDAmeritradeInterface

Ticker List
    - Show 12-mo dividend yield
    - Allow it to replace the tickers Excel sheet
    - Tags with each ticker
    
    