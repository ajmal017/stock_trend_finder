select symbol, datelist.price_date, close from (select distinct price_date from daily_stock_prices order by price_date desc) as datelist left join 
	tickers on 1=1 left join
		daily_stock_prices on tickers.id=daily_stock_prices.ticker_id and datelist.price_date=daily_stock_prices.price_date
where 
datelist.price_date > (select min(price_date) from daily_stock_prices where ticker_id=tickers.id) and 
close is null and
symbol in (select symbol from tickers where watch=true)
order by symbol, price_date desc;

--select symbol, price_date, close from daily_stock_prices 
--	inner join tickers on tickers.id=daily_stock_prices.ticker_id
 --and
--price_date not in (select distinct price_date from daily_stock_prices order by price_date desc)
