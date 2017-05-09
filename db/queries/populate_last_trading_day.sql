update daily_stock_prices as dsp_upd set days_since_previous_trading_day=
	(select last_trading_day from 
		(select 
			dsp1.id,
			dsp1.ticker_id, 
			symbol, 
			dsp1.price_date, 
			(select dsp2.price_date from daily_stock_prices as dsp2 where dsp2.ticker_id=dsp1.ticker_id and dsp2.id<dsp1.id order by price_date desc limit 1) 
				as previous_price_date,
			dsp1.price_date -(select max(dsp2.price_date) from daily_stock_prices as dsp2 where dsp2.ticker_id=dsp1.ticker_id and dsp2.id<dsp1.id) as last_trading_day 
		from daily_stock_prices as dsp1
		inner join tickers on ticker_id=tickers.id
		where dsp1.ticker_id=dsp_upd.ticker_id and dsp1.price_date=dsp_upd.price_date
		) as query_last_trading_day
	)
	where dsp_upd.days_since_previous_trading_day is null
	--and dsp_upd.id in (select id from daily_stock_prices dsp_select where dsp_select.days_since_previous_trading_day is null limit 1000);
--where dsp_upd.ticker_id=164 and dsp_upd.price_date>'01-01-2013'