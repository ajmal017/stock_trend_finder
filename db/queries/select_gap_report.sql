select tickers.id, tickers.symbol, price_date, open, high, low, close, close_5day, high_5day, low_5day, close_10day, high_10day, low_10day, close_30day, high_30day, low_30day, close_60day, high_60day, low_60day, low_pct_of_previous_day_high, close_pct_of_previous_day_high, days_since_previous_trading_day from daily_stock_prices 
inner join tickers on ticker_id=tickers.id
where low_higher_than_previous_day_high=true and low_pct_of_previous_day_high>1.01
order by price_date desc