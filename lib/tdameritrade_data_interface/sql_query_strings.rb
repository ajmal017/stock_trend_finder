module TDAmeritradeDataInterface
  module SQLQueryStrings
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def select_active_stocks
        <<SQL
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
dsp.price_date = (select price_date from daily_stock_prices dspd where dspd.ticker_id=rtq.ticker_id and dspd.price_date < date_trunc('day', rtq.quote_time) order by price_date desc limit 1) and
(last_trade * rtq.volume > 1000000) and
abs(round(((last_trade / dsp.close) - 1) * 100, 2)) > 1 and
average_volume_50day is not null
order by volume_ratio desc
limit 50
SQL
      end

      def select_ema13_bullish_breaks

      end

      def select_hammers
        <<SQL
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
(volume * last_trade  > 3000000) and
(round(volume / ((select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000), 2)  > 1)
order by average_volume_ratio desc
SQL
      end

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