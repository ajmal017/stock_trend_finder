select ticker_id, ticker_symbol, price_date, open, high, low, close, previous_close, previous_high, previous_low, open_higher_than_previous_day_high, open/previous_high as open_pct_of_previous_high from daily_stock_prices
inner join tickers on tickers.id=daily_stock_prices.ticker_id
where open/previous_high > 1.02 and open!=0 and previous_high!=0 and tickers.track_gap_up
order by price_date
