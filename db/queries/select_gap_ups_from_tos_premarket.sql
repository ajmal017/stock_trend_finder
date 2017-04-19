--select * from daily_stock_prices where ticker_symbol='ONE' order by price_date desc
--select * from tickers where symbol='JMI'--id=4244
select 
  ticker_id,
  ticker_symbol,
  last_trade,
  open,
  low,
  quote_time, 
  (select high as previous_high from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id and dsp.price_date < date_trunc('day', rtq.quote_time) order by price_date desc limit 1) as previous_high,
  round(open / (select high as previous_high from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id and dsp.price_date < date_trunc('day', rtq.quote_time) order by price_date desc limit 1),3) as gap_up_pct,
  round(low / (select high as previous_high from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id and dsp.price_date < date_trunc('day', rtq.quote_time) order by price_date desc limit 1),3) as last_trade_pct,
  (select adr from tickers where tickers.id=rtq.ticker_id) as adr,
  low < open as dipping
from real_time_quotes as rtq
where (select track_gap_up from tickers where tickers.id=rtq.ticker_id) 
