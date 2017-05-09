-- update the first entry - 13SMA
update daily_stock_prices dsp set ema13=round(((select avg(close) from (select close from daily_stock_prices where ticker_symbol=dsp.ticker_symbol and price_date <= '2014-03-13' order by price_date desc limit 13) as dsp_sma)),2)
where
dsp.ticker_symbol in (select symbol from tickers where scrape_data=true) and
price_date='2014-03-13' and
dsp.ticker_symbol in (select distinct ticker_symbol from daily_stock_prices where price_date > '2014-01-01' and ema13 is null)


-- or (to populate the first available for the ticker and not just a specific date)

update daily_stock_prices dsp
set
 ema13=
 round((
    (select avg(close) from
    (select close from daily_stock_prices
    where
    ticker_symbol=dsp.ticker_symbol and
    price_date <= (select price_date from daily_stock_prices dsp_pd where dsp_pd.ticker_symbol=dsp.ticker_symbol order by price_date offset 12 limit 1)
    order by price_date desc limit 13) as dsp_sma)),
 2)
where
dsp.ticker_symbol in (select symbol from tickers where scrape_data=true) and
price_date=(select price_date from daily_stock_prices dsp_pd where dsp_pd.ticker_symbol=dsp.ticker_symbol order by price_date offset 12 limit 1) and
dsp.ticker_symbol in (select distinct ticker_symbol from daily_stock_prices where price_date > '2012-01-01' and ema13 is null)



-- update subsequent 13EMAs

with ticker_list as (
select distinct ticker_symbol from daily_stock_prices
where
ema13 is not null and
ticker_symbol in (select symbol from tickers where scrape_data=true) and
exists (select price_date from daily_stock_prices where ticker_symbol=dsp_tl.ticker_symbol and price_date > '2014-06-30' and ema13 is null)
)
--select * from ticker_list
,
ticker_price_date as (
select id, ticker_symbol, price_date, close,
(select ema13 from daily_stock_prices dsp_last_ema where dsp_last_ema.ticker_symbol=dsp_tpd.ticker_symbol and dsp_last_ema.price_date<dsp_tpd.price_date order by price_date desc limit 1) as last_ema13,
(select price_date from daily_stock_prices dsp_first_ema where dsp_first_ema.ticker_symbol=dsp_tpd.ticker_symbol and dsp_first_ema.ema13 is not null order by dsp_first_ema.price_date limit 1) as first_ema13_date
from daily_stock_prices dsp_tpd
--where ticker_symbol in ('AAOI', 'SINA', 'KNDI', 'TWTR') and
where ticker_symbol in (select * from ticker_list) and
price_date>(select price_date from daily_stock_prices dsp_first_ema where dsp_first_ema.ticker_symbol=dsp_tpd.ticker_symbol and dsp_first_ema.ema13 is not null order by dsp_first_ema.price_date limit 1) and
price_date = '2012-08-15' --(select price_date from daily_stock_prices where ticker_symbol=dsp_tpd.ticker_symbol and ema13 is not null order by price_date desc limit 1)
)

update daily_stock_prices dsp set ema13=

(round(
(select close from ticker_price_date where ticker_price_date.id=dsp.id) * (0.142857) +
(select last_ema13 from ticker_price_date where ticker_price_date.id=dsp.id) * (1-(0.142857)), 2))

where dsp.id in (select id from ticker_price_date)

--select * from ticker_price_date


-- update subsequent 13EMAs version 2
with ema_update_list as (
select id, ticker_symbol, price_date, close, ema13,
(select ema13 from daily_stock_prices dsp_last_ema where dsp_last_ema.ticker_symbol=dsp_ul.ticker_symbol and dsp_last_ema.price_date<dsp_ul.price_date order by price_date desc limit 1) as last_ema13
from daily_stock_prices dsp_ul
where
price_date='2012-03-19' and
ema13 is null and
(select ema13 from daily_stock_prices dsp_last_ema where dsp_last_ema.ticker_symbol=dsp_ul.ticker_symbol and dsp_last_ema.price_date<dsp_ul.price_date order by price_date desc limit 1) is not null
)

update daily_stock_prices dsp set ema13=

(round(
(select close from ema_update_list where ema_update_list.id=dsp.id) * (0.142857) +
(select last_ema13 from ema_update_list where ema_update_list.id=dsp.id) * (1-(0.142857)), 2))

where dsp.id in (select id from ema_update_list)

-- initial draft
update daily_stock_prices dsp_upd set
ema13=(round(
(select close from daily_stock_prices
where ticker_symbol=dsp_upd.ticker_symbol and price_date=dsp_upd.price_date
order by price_date desc
limit 1) * (0.142857) +
(
select coalesce(ema13,0) from daily_stock_prices
where ticker_symbol=dsp_upd.ticker_symbol and price_date<dsp_upd.price_date
order by price_date desc
limit 1
) * (1-(0.142857)), 2)
) where price_date = '2014-06-27' and ticker_symbol='AAOI'