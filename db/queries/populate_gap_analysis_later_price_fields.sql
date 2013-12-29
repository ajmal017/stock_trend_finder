update daily_stock_prices as dsp_upd set
	close_5day=(select close from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 1 offset 4),
	high_5day=(select max(high) from (select high from daily_stock_prices as dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 5) as p5high),
	low_5day=(select min(low) from (select low from daily_stock_prices as dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 5) as p5low),
	close_10day=(select close from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 1 offset 9),
	high_10day=(select max(high) from (select high from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 10) as p10high),
	low_10day=(select min(low) from (select low from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 10) as p10low),
	close_30day=(select close from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 1 offset 29),
	high_30day=(select max(high) from (select high from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 30) as p30high),
	low_30day=(select min(low) from (select low from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 30) as p30low),
	close_60day=(select close from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 1 offset 59),
	high_60day=(select max(high) from (select high from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 60) as p60high),
	low_60day=(select min(low) from (select low from daily_stock_prices dsp where dsp.price_date>dsp_upd.price_date and dsp.ticker_id=dsp_upd.ticker_id order by dsp.price_date asc limit 60) as p60low)

where dsp_upd.low_higher_than_previous_day_high=true and dsp_upd.low_pct_of_previous_day_high>1.01 --and dsp_upd.ticker_id=2888