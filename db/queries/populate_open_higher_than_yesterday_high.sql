update daily_stock_prices as dsp_upd set open_higher_than_previous_day_high=
	(select open_higher 
	from (select 
		dsp1.id,
		dsp1.ticker_id, 
		symbol, 
		dsp1.price_date,
		dsp1.open,
		(select high 
			from daily_stock_prices as dsp2
			where dsp2.ticker_id=dsp1.ticker_id and dsp2.price_date<dsp1.price_date
			order by dsp2.price_date desc
			limit 1
		) as previous_high,
		dsp1.open > (select high 
			from daily_stock_prices as dsp2
			where dsp2.ticker_id=dsp1.ticker_id and dsp2.price_date<dsp1.price_date
			order by dsp2.price_date desc
			limit 1
		) as open_higher
		from daily_stock_prices as dsp1
		inner join tickers on ticker_id=tickers.id
		where dsp1.ticker_id=dsp_upd.ticker_id and dsp1.price_date=dsp_upd.price_date
		) as open_higher_than_previous_day_high_value
	)
--where dsp_upd.ticker_id=164