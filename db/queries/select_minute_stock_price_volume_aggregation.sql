select msp.ticker_symbol, sum(msp.volume) as volume, dsp.average_volume_50day, round(sum(msp.volume) / dsp.average_volume_50day, 2) as volume_ratio, dsp.close as dsp_close, 

(round((
select mspch.close from minute_stock_prices mspch
where mspch.ticker_id=msp.ticker_id and price_time < '2014-05-23 10:15:00'
order by price_time desc
limit 1
) / dsp.close, 4) - 1) * 100 
as change

from minute_stock_prices msp inner join
daily_stock_prices dsp on msp.ticker_id=dsp.ticker_id
where
dsp.average_volume_50day > 0 and 
price_time < '2014-05-23 10:15:00' and price_time > '2014-05-23 00:00:00' and
dsp.price_date = (select price_date from daily_stock_prices where price_date<'2014-05-23' order by price_date desc limit 1)
group by msp.ticker_symbol, dsp.average_volume_50day, dsp.price_date, dsp.close, change
having sum(msp.volume) > 3000
order by volume_ratio desc

