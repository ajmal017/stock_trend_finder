-- select hammers
select ticker_symbol, open, high, low, last_trade, volume, quote_time,
(select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000 as average_volume_50day,
round(volume / ((select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000), 2) as average_volume_ratio 
from real_time_quotes rtq
where
last_trade != 0 and open != 0 and high != 0 and low != 0 and high != low and
(abs(last_trade - open) / (high - low) < 0.33) and
((high - low) / last_trade > 0.05) and
(
((greatest(last_trade, open)  - low) / (high-low) > 0.95) or
((least(last_trade, open) - low + 0.001) / (high-low) < 0.05)
) and
(volume * last_trade  > 5000000) and
(round(volume / ((select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000), 2)  > 1)
order by average_volume_ratio desc


--select and long tailed candles at the top or bottom of a 5-day trend  (8/31/14)
select rtq.ticker_symbol, rtq.open, rtq.high, rtq.low, last_trade,
round(((last_trade / dsp.close) - 1) * 100, 2) as pct_change,
rtq.volume, quote_time,
(select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000 as average_volume,
round(rtq.volume / ((select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000), 2) as volume_ratio,
tix.float as float
from real_time_quotes rtq inner join tickers tix on rtq.ticker_symbol=tix.symbol inner join daily_stock_prices dsp on dsp.ticker_id=rtq.ticker_id
where
last_trade != 0 and rtq.open != 0 and rtq.high != 0 and rtq.low != 0 and rtq.high != rtq.low and
(abs(last_trade - rtq.open) / (rtq.high - rtq.low) < 0.5) and
(rtq.volume * last_trade  > 5000000) and
(round(rtq.volume / ((select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000), 2)  > 1) and
dsp.price_date = (select price_date from daily_stock_prices dspd where dspd.ticker_id=rtq.ticker_id and dspd.price_date < date_trunc('day', rtq.quote_time) order by price_date desc limit 1) and
tix.scrape_data
order by volume_ratio desc
