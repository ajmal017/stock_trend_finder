module TDAmeritradeDataInterface
  module SQLQueryStrings
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def update_average_volume_50day(begin_date)
        raise Exception.new("No begin_date given for update_average_volume_50day query") if begin_date.nil?
        <<SQL
update daily_stock_prices dsp_upd set
average_volume_50day=(
select round(avg(volume)) from (select id, price_date, ticker_symbol, volume from daily_stock_prices
where ticker_symbol=dsp_upd.ticker_symbol and price_date<dsp_upd.price_date
order by price_date desc
limit 50) as sel_vol_range
)
where price_date > '#{begin_date.strftime('%Y-%m-%d')}' and average_volume_50day is null
SQL
      end

      def update_ema13_first_sma(begin_date)
        <<SQL

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
dsp.ticker_symbol in (select distinct ticker_symbol from daily_stock_prices where price_date > '#{begin_date.strftime('%Y-%m-%d')}' and ema13 is null)

SQL
      end

      def update_ema13(begin_date)
        <<SQL
with ema_update_list as (
select id, ticker_symbol, price_date, close, ema13,
(select ema13 from daily_stock_prices dsp_last_ema where dsp_last_ema.ticker_symbol=dsp_ul.ticker_symbol and dsp_last_ema.price_date<dsp_ul.price_date order by price_date desc limit 1) as last_ema13
from daily_stock_prices dsp_ul
where
price_date='#{begin_date.strftime('%Y-%m-%d')}' and
ema13 is null and
(select ema13 from daily_stock_prices dsp_last_ema where dsp_last_ema.ticker_symbol=dsp_ul.ticker_symbol and dsp_last_ema.price_date<dsp_ul.price_date order by price_date desc limit 1) is not null
)

update daily_stock_prices dsp set ema13=

(round(
(select close from ema_update_list where ema_update_list.id=dsp.id) * (0.142857) +
(select last_ema13 from ema_update_list where ema_update_list.id=dsp.id) * (1-(0.142857)), 2))

where dsp.id in (select id from ema_update_list)
SQL
      end

      def update_candle_vs_ema13
        <<SQL
update daily_stock_prices
set candle_vs_ema13=(case
  when high < ema13 then 'below'
  when low > ema13 then 'above'
  else 'middle'
end)
where ema13 is not null and candle_vs_ema13 is null
SQL
      end

    end

  end
end