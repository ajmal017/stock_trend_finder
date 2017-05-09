with dt as (
select 
ticker_symbol, 
round(avg(volume)) as avg_volume, 
(select close from daily_stock_prices as dsp_in where dsp_in.ticker_symbol=dsp_out.ticker_symbol order by price_date desc limit 1) as last_price, 
(select close from daily_stock_prices as dsp_in where dsp_in.ticker_symbol=dsp_out.ticker_symbol order by price_date desc limit 1) * round(avg(volume)) as dollars_traded 
from daily_stock_prices as dsp_out where price_date > '8/1/2013' group by ticker_symbol order by ticker_symbol
)
update tickers as tix set track_gap_up=false where (select dollars_traded from dt where dt.ticker_symbol=tix.symbol)<600000