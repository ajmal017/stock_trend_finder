-- transfer data from rtq table to daily_stock_prices
insert into daily_stock_prices (ticker_id, ticker_symbol, price_date, open, high, low, close, volume, created_at, updated_at, snapshot_time)
select ticker_id, ticker_symbol, date(quote_time), open, high, low, last_trade, volume/1000, current_timestamp, current_timestamp, quote_time
from real_time_quotes rtq
where ticker_symbol not in (select ticker_symbol from daily_stock_prices dsp where dsp.price_date=date(rtq.quote_time))

-- update
update daily_stock_prices as dsp
set
(open, high, low, close, volume, updated_at, snapshot_time,previous_close,average_volume_50day,ema13,candle_vs_ema13)=
(rtq.open, rtq.high, rtq.low, rtq.last_trade, rtq.volume/1000, current_timestamp, rtq.quote_time, null, null, null, null)
from real_time_quotes rtq
where dsp.ticker_symbol=rtq.ticker_symbol and dsp.price_date=date(rtq.quote_time)
