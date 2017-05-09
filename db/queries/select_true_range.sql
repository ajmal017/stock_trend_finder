-- select a list of true ranges for a given stock
select ticker_symbol, price_time, ticker_symbol, open, high, low, close, true_range, average_true_range_60,
(select round(avg(true_range),4) from (select true_range from stock_prices15_minutes where ticker_symbol=sp.ticker_symbol and price_time<=sp.price_time order by price_time desc limit 60) as spatr) as average_true_range_60
from stock_prices15_minutes sp
where
ticker_symbol='VXX'
order by price_time desc

-- select a report of TrueRangeVsAvgTrueRange above a certain threshold
