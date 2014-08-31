-- active stocks
select
  rtq.ticker_symbol,
  last_trade,
  round(((last_trade / dsp.close) - 1) * 100, 2) as pct_change,
  dsp.close as prev_close,
  round(rtq.volume / 1000) as volume,
  dsp.average_volume_50day as average_volume,
  round(round(rtq.volume / 1000) / dsp.average_volume_50day, 2) as volume_ratio,
  quote_time,
  dsp.price_date as last_price_date

from real_time_quotes as rtq inner join
daily_stock_prices dsp on dsp.ticker_id=rtq.ticker_id inner join
tickers tix on tix.id=rtq.ticker_id
where
tix.scrape_data=true and
rtq.last_trade > 1 and
dsp.price_date = (select price_date from daily_stock_prices dspd where dspd.ticker_id=rtq.ticker_id and dspd.price_date < date_trunc('day', rtq.quote_time) order by price_date desc limit 1) and
(last_trade * rtq.volume > 2000000) and
abs(round(((last_trade / dsp.close) - 1) * 100, 2)) > 1 and
average_volume_50day is not null
order by volume_ratio desc
limit 50

-- active stocks on a past day by aggregate volume
select
  ticker_symbol,
  close,
  volume,
  average_volume_50day as average_volume,
  round(round(volume) / average_volume_50day, 2) as volume_ratio,
  price_date

from daily_stock_prices
where
price_date = '2014-07-31' and
volume > 5000 and
average_volume_50day is not null
order by volume_ratio desc
limit 50