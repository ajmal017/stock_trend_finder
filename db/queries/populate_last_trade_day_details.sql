update daily_stock_prices as dsp_upd set
  previous_trading_day=
	(
	select price_date from daily_stock_prices where ticker_id=dsp_upd.ticker_id and price_date<dsp_upd.price_date order by price_date desc limit 1
	), 
 days_since_previous_trading_day=
	(
	select (price_date-previous_trading_day) from daily_stock_prices where ticker_id=dsp_upd.ticker_id and price_date<dsp_upd.price_date order by price_date desc limit 1
	),
 previous_close=
	(
	select close from daily_stock_prices where ticker_id=dsp_upd.ticker_id and price_date<dsp_upd.price_date order by price_date desc limit 1
	),
 previous_high=
	(
	select high from daily_stock_prices where ticker_id=dsp_upd.ticker_id and price_date<dsp_upd.price_date order by price_date desc limit 1
	),
 previous_low=
	(
	select low from daily_stock_prices where ticker_id=dsp_upd.ticker_id and price_date<dsp_upd.price_date order by price_date desc limit 1
	)

	where dsp_upd.days_since_previous_trading_day is null
	--where dsp_upd.id in (select id from daily_stock_prices dsp_select where dsp_select.days_since_previous_trading_day is null limit 100000)

--where ticker_id=3262 and price_date < '2011-05-25'


--select price_date, open, high, low, close,
--	(
--	select price_date from daily_stock_prices where ticker_id=3262 and price_date<dsp_upd.price_date order by price_date desc limit 1
--	) as previous_trading_day,
--	(
--	select close from daily_stock_prices where ticker_id=3262 and price_date<dsp_upd.price_date order by price_date desc limit 1
--	) as previous_close,
--	(
--	select high from daily_stock_prices where ticker_id=3262 and price_date<dsp_upd.price_date order by price_date desc limit 1
--	) as previous_high,
--	(
--	select low from daily_stock_prices where ticker_id=3262 and price_date<dsp_upd.price_date order by price_date desc limit 1
--	) as previous_low
-- from daily_stock_prices as dsp_upd where ticker_id=3262 and price_date < '2011-05-25'
