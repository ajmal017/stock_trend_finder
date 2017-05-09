-- a select query for test/debug purposes
select ticker_symbol, price_date, high, low, ema13,
case
  when high < ema13 then 'below'
  when low > ema13 then 'above'
  else 'middle'
end as candle_vs_ema13

from daily_stock_prices
limit 200


-- the actual update query
update daily_stock_prices
set candle_vs_ema13=(case
  when high < ema13 then 'below'
  when low > ema13 then 'above'
  else 'middle'
end)
where ema13 is not null and candle_vs_ema13 is null