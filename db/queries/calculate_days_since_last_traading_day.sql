select 
			dsp1.id,
			dsp1.ticker_id, 
			symbol, 
			dsp1.price_date, 
			(select max(dsp2.price_date) from daily_stock_prices as dsp2 where dsp2.ticker_id=dsp1.ticker_id and dsp2.id<dsp1.id) 
				as previous_price_date,
			dsp1.price_date -(select max(dsp2.price_date) from daily_stock_prices as dsp2 where dsp2.ticker_id=dsp1.ticker_id and dsp2.id<dsp1.id) as last_trading_day 
		from daily_stock_prices as dsp1
		inner join tickers on ticker_id=tickers.id
		limit 100