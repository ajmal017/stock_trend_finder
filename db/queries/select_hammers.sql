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