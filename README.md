Winston's Stock Trend Finder Utilities
--------------------------------------

[![Build Status](https://travis-ci.org/wakproductions/tdameritrade_api.svg?branch=master)](https://travis-ci.org/wakproductions/tdameritrade_api)

You will not find this to be a usable application. The only reason this is on
Github is to discuss and collaborate with other people who are interested in
how I'm using Ruby on Rails as a finance tool.

Stock Trend Finder is a work in progress that I am using to scan for technical analysis 
based trade opportunities in the stock market. Most of the working code is in the lib 
folder where several routines are used to download historical data from TD Ameritrade 
and put them into a Postgres database. The database is denomalized in some ways for 
speed and used for calculations to find situations such as moving average breaks,
unusual volume patterns, and daily gap ups/gap downs on a universe of 4500 stocks.
I most actively update import_daily_quotes.rb and sql_query_strings.rb as I tweak
my trading strategies. You will probably notice that many of the queries are run
as direct SQL queries rather than the ActiveRecord way simply because the queries
can get very complex when doing aggregate calculations and it's much easier
and efficient on the computer to maintain the SQL directly.

In the lib/tasks folder I have a daemons.rake file, which is the core of my stock
scanning system. I always have this rake task running in the background and it
periodically retrieves fresh pricing data from the markets to update my scans.
I also recently added a secondary feature where it downloads Stocktwits from my
favorite bloggers so that I can catalog and review what other trading experts
are thinking on specific stocks.

The models, controllers, and views provide me an interface for analyzing the
data downloaded by the daemons. I run the Rails application in the background
and use the web browser to review my scans throughout the day.

## New Concepts

* lib/reports - use to build reports from the data currently cached in the database
* lib/market_data_pull - use to fetch new data from market data sources in the cloud and populate the DB


