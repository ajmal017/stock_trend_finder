--with low_liquidity_quarters as
truncate table low_liquidity_quarters;
insert into low_liquidity_quarters (ticker_id, ticker_symbol, quarter, year, low_liquidity_days)
(select 
	ticker_id, ticker_symbol, pd.quarter as quarter, pd.year, count((high=low) and (open=close)) as low_liquidity_days 		
from daily_stock_prices lldsp
inner join price_dates pd on lldsp.price_date=pd.price_date 
where ((high=low) and (open=close))
group by ticker_id, ticker_symbol, quarter, year
having count((high=low) and (open=close)) > 7 
order by year, quarter
);--,

--price_dates_and_tickers_to_screen as
--(select dsp.id as dsp_id, ll.ticker_id, ll.ticker_symbol, ll.quarter, ll.year, low_liquidity_days, dsp.price_date from low_liquidity_quarters ll
--inner join price_dates pd on ll.year=pd.year and ll.quarter=pd.quarter
--inner join daily_stock_prices dsp on ll.ticker_id=dsp.ticker_id and dsp.price_date=pd.price_date
--where low_liquidity_days > 7
--order by dsp.price_date)

--select dsp_id from price_dates_and_tickers_to_screen as screendsp