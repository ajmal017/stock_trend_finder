update daily_stock_prices as dsp_upd set open_higher_than_previous_day_high=
	(select open_higher from 
		(select 
			dsp1.id,
			dsp1.ticker_id, 
			symbol, 
			dsp1.price_date,
			dsp1.open > (select open from daily_stock_prices as dsp2 where dsp2.ticker_id=dsp1.ticker_id and dsp2.id<dsp1.id and dsp2.price_date=max(dsp2.price_date)) as open_higher, 
			(select max(dsp2.price_date) from daily_stock_prices as dsp2 where dsp2.ticker_id=dsp1.ticker_id and dsp2.id<dsp1.id) 
				as previous_price_date,
			dsp1.price_date -(select max(dsp2.price_date) from daily_stock_prices as dsp2 where dsp2.ticker_id=dsp1.ticker_id and dsp2.id<dsp1.id) as last_trading_day 
		from daily_stock_prices as dsp1
		inner join tickers on ticker_id=tickers.id
		where dsp1.ticker_id=dsp_upd.ticker_id and dsp1.price_date=dsp_upd.price_date
		) as query_last_trading_day
	
	)
where dsp_upd.ticker_id=164 and dsp_upd.price_date>'01-01-2013'