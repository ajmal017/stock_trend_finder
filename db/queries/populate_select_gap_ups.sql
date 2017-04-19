truncate table gap_ups;
insert into gap_ups
(ticker_id, ticker_symbol, price_date, open, high, low, close, previous_close, previous_high, previous_low, open_pct_of_previous_high, last_year_close, pct_of_last_year_close)
	select ticker_id, ticker_symbol, price_date, open, high, low, close, previous_close, previous_high, previous_low, round(open/previous_high,4) as open_pct_of_previous_high, 
	(select lyc.close from daily_stock_prices lyc where lyc.ticker_id=dsp.ticker_id and lyc.price_date<=dsp.price_date order by price_date desc offset 252 limit 1) as last_year_close,
	(select round(dsp.close/lyc.close,2) from daily_stock_prices lyc where lyc.ticker_id=dsp.ticker_id and lyc.price_date<=dsp.price_date order by price_date desc offset 252 limit 1) as pct_of_last_year_close 
	from daily_stock_prices dsp
inner join tickers on tickers.id=dsp.ticker_id
where exclude=false and tickers.track_gap_up and open/previous_high > 1.015
--order by price_date
--limit 100
