--update daily_stock_prices set range_pct=(case when low=0 then 0 else high/low end)
select ticker_symbol, round(avg(range_pct), 4) as average, max(range_pct) as high, round(stddev(range_pct), 4) as stdev
from daily_stock_prices
group by ticker_symbol 