--with dsp_all as (
--select id, ticker_symbol, price_date, volume from daily_stock_prices
--)

update daily_stock_prices dsp_upd set
average_volume_50day=(
select round(avg(volume)) from (select id, price_date, ticker_symbol, volume from daily_stock_prices
where ticker_symbol=dsp_upd.ticker_symbol and price_date<dsp_upd.price_date
order by price_date desc
limit 50) as sel_vol_range
)
where average_volume_50day is null
--where ticker_symbol='ZU' and price_date='2014-05-07'

--select round(avg(volume)) from
--(
--select id, price_date, ticker_symbol, volume from daily_stock_prices
--where ticker_symbol='ZU' and price_date<'2014-05-12'
--order by price_date desc
--limit 50
--) as price_dates

--select * from daily_stock_prices where ticker_symbol='ZU' and price_date='2014-05-07' limit 1