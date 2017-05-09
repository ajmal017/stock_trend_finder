select symbol, datelist.price_date from tickers inner join 
	daily_stock_prices on tickers.id=daily_stock_prices.ticker_id left outer join
		(select distinct price_date from daily_stock_prices order by price_date desc) as datelist on daily_stock_prices.price_date=datelist.price_date;