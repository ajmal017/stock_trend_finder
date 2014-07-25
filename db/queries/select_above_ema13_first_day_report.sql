-- ema breaks based on real time quoets
select ticker_symbol, quote_time, high, low, last_trade>open as green_candle,


round(
(last_trade * (0.142857) +
(select ema13 from daily_stock_prices where daily_stock_prices.ticker_symbol=rtq.ticker_symbol order by price_date desc limit 1) * (1-(0.142857))),
2)

 as ema13,
(case
  when high < round(
(last_trade * (0.142857) +
(select ema13 from daily_stock_prices where daily_stock_prices.ticker_symbol=rtq.ticker_symbol order by price_date desc limit 1) * (1-(0.142857))),
2) then 'below'
  when low > round(
(last_trade * (0.142857) +
(select ema13 from daily_stock_prices where daily_stock_prices.ticker_symbol=rtq.ticker_symbol order by price_date desc limit 1) * (1-(0.142857))),
2) then 'above'
  else 'middle'
end) as candle_vs_ema13,
round(volume/1000/(select average_volume_50day from daily_stock_prices dsp where dsp.ticker_symbol=rtq.ticker_symbol order by price_date desc limit 1), 2) as volume_ratio from real_time_quotes rtq
where
(case
  when high < round(
(last_trade * (0.142857) +
(select ema13 from daily_stock_prices where daily_stock_prices.ticker_symbol=rtq.ticker_symbol order by price_date desc limit 1) * (1-(0.142857))),
2) then 'below'
  when low > round(
(last_trade * (0.142857) +
(select ema13 from daily_stock_prices where daily_stock_prices.ticker_symbol=rtq.ticker_symbol order by price_date desc limit 1) * (1-(0.142857))),
2) then 'above'
  else 'middle'
end)='above' and
(select count(candle_vs_ema13) from (select candle_vs_ema13 from daily_stock_prices dsp_cve where dsp_cve.ticker_symbol=rtq.ticker_symbol and dsp_cve.price_date<rtq.quote_time order by price_date desc limit 7) as dsp_inner where candle_vs_ema13!='above')
=7 and
(select scrape_data from tickers where tickers.symbol=rtq.ticker_symbol)=true and
volume * last_trade > 1000000
order by volume_ratio desc



-- for any day in the daily_price_history table
select ticker_symbol, price_date, high, low, ema13, close > open as green_candle, candle_vs_ema13, round(volume/average_volume_50day, 2) as volume_ratio from daily_stock_prices dsp
where
candle_vs_ema13='above' and
price_date='2014-04-04' and
(select count(candle_vs_ema13) from (select candle_vs_ema13 from daily_stock_prices dsp_cve where dsp_cve.ticker_symbol=dsp.ticker_symbol and dsp_cve.price_date<dsp.price_date order by price_date desc limit 7) as dsp_inner where candle_vs_ema13!='above')
=7 and
(select scrape_data from tickers where tickers.symbol=dsp.ticker_symbol)=true and
volume * 1000 * close > 5000000
order by volume_ratio desc