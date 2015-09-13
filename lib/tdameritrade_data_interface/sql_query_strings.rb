module TDAmeritradeDataInterface
  module SQLQueryStrings
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def select_active_stocks(most_recent_date)
        <<SQL
select
  ticker_symbol,
  close,
  round(((close / previous_close) - 1) * 100, 2) as pct_change,
  previous_close,
  volume,
  average_volume_50day as average_volume,
  round(volume / average_volume_50day, 2) as volume_ratio,
  price_date,
  float,
  snapshot_time

from daily_stock_prices d inner join tickers t on t.id=d.ticker_id
where
t.scrape_data=true and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
abs((round(((close / previous_close) - 1) * 100, 2))) > 4 and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
(close * volume > 5000)
order by volume_ratio desc
limit 50
SQL
      end

      def select_ema13_bullish_breaks
        <<SQL
        with last_7_days as (
                                select ticker_symbol, price_date, close, round(close/previous_close, 2) as pct_change, volume, average_volume_50day as average_volume, round(volume / dsp.average_volume_50day, 2) as volume_ratio, candle_vs_ema13, tix.float from daily_stock_prices dsp inner join tickers tix on dsp.ticker_id=tix.id
        where price_date in (select distinct price_date from daily_stock_prices dsppd order by dsppd.price_date desc limit 7) and
            tix.scrape_data = true and
            volume * 1000 * close > 5000000
        order by dsp.price_date desc
        )
        select ticker_symbol, price_date, close as last_trade, pct_change, volume, average_volume, volume_ratio, candle_vs_ema13, float from last_7_days lsd
        where
        candle_vs_ema13='above' and
            price_date = (select price_date from last_7_days limit 1) and
            (select count(candle_vs_ema13) from last_7_days lsd_count where lsd_count.ticker_symbol=lsd.ticker_symbol and lsd_count.price_date<lsd.price_date and lsd_count.candle_vs_ema13!='above')>3
        order by volume_ratio desc
SQL
      end

      def select_hammers
        <<SQL
select rtq.ticker_symbol, rtq.open, rtq.high, rtq.low, last_trade,
round(((last_trade / dsp.close) - 1) * 100, 2) as pct_change,
rtq.volume, quote_time,
(select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000 as average_volume,
round(rtq.volume / ((select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000), 2) as volume_ratio,
tix.float as float
from real_time_quotes rtq inner join tickers tix on rtq.ticker_symbol=tix.symbol inner join daily_stock_prices dsp on dsp.ticker_id=rtq.ticker_id
where
(tix.hide_from_reports_until is null or tix.hide_from_reports_until <= current_date) and
last_trade != 0 and rtq.open != 0 and rtq.high != 0 and rtq.low != 0 and rtq.high != rtq.low and
(abs(last_trade - rtq.open) / (rtq.high - rtq.low) < 0.5) and
(rtq.volume * last_trade  > 5000000) and
(round(rtq.volume / ((select average_volume_50day from daily_stock_prices dsp where dsp.ticker_id=rtq.ticker_id order by price_date desc limit 1) * 1000), 2)  > 1) and
dsp.price_date = (select price_date from daily_stock_prices dspd where dspd.ticker_id=rtq.ticker_id and dspd.price_date < date_trunc('day', rtq.quote_time) order by price_date desc limit 1) and
tix.scrape_data
order by volume_ratio desc
SQL
      end

      def select_4_green_candles(most_recent_date)
        <<SQL
with last_4_days as (
select ticker_symbol, price_date, high, low, close, (round(close/previous_close, 2)-1)*100 as pct_change, volume, average_volume_50day as average_volume, round(volume / dsp.average_volume_50day, 2) as volume_ratio, candle_vs_ema13, tix.float,
case
  when close > open then 'green'
  when close < open then 'red'
  else 'grey'
end as candle_color
from daily_stock_prices dsp inner join tickers tix on dsp.ticker_id=tix.id
where
price_date in (select distinct price_date from daily_stock_prices dsppd where dsppd.price_date <= '#{most_recent_date.strftime('%Y-%m-%d')}' order by dsppd.price_date desc limit 4) and
tix.scrape_data = true and
volume * 1000 * close > 5000000
order by dsp.price_date desc
)
select ticker_symbol, price_date, high, low, close, pct_change, volume, average_volume, volume_ratio, float, candle_color,
(round(close / (select low from last_4_days lfdpd where lfdpd.ticker_symbol=lfd.ticker_symbol order by price_date limit 1), 4)-1)*100 as pct_change_4day
from last_4_days lfd
where
(select count(candle_color) from last_4_days lfdcc where lfdcc.ticker_symbol=lfd.ticker_symbol and lfdcc.candle_color='green') = 4 and
lfd.price_date = (select price_date from last_4_days lfdpd where lfdpd.ticker_symbol=lfd.ticker_symbol order by price_date desc limit 1) and
lfd.close / (select low from last_4_days lfdpd where lfdpd.ticker_symbol=lfd.ticker_symbol order by price_date limit 1) > 1.07
order by ticker_symbol desc
SQL
      end

      def select_4_red_candles(most_recent_date)
        <<SQL
with last_4_days as (
select ticker_symbol, price_date, high, low, close, (round(close/previous_close, 2)-1)*100 as pct_change, volume, average_volume_50day as average_volume, round(volume / dsp.average_volume_50day, 2) as volume_ratio, candle_vs_ema13, tix.float,
case
  when close > open then 'green'
  when close < open then 'red'
  else 'grey'
end as candle_color
from daily_stock_prices dsp inner join tickers tix on dsp.ticker_id=tix.id
where
price_date in (select distinct price_date from daily_stock_prices dsppd where dsppd.price_date <= '#{most_recent_date.strftime('%Y-%m-%d')}' order by dsppd.price_date desc limit 4) and
tix.scrape_data = true and
volume * 1000 * close > 5000000
order by dsp.price_date desc
)
select ticker_symbol, price_date, high, low, close, pct_change, volume, average_volume, volume_ratio, float, candle_color,
(round(close / (select low from last_4_days lfdpd where lfdpd.ticker_symbol=lfd.ticker_symbol order by price_date limit 1), 4)-1)*100 as pct_change_4day
from last_4_days lfd
where
(select count(candle_color) from last_4_days lfdcc where lfdcc.ticker_symbol=lfd.ticker_symbol and lfdcc.candle_color='red') = 4 and
lfd.price_date = (select price_date from last_4_days lfdpd where lfdpd.ticker_symbol=lfd.ticker_symbol order by price_date desc limit 1) and
lfd.close / (select low from last_4_days lfdpd where lfdpd.ticker_symbol=lfd.ticker_symbol order by price_date limit 1) < 0.93
order by ticker_symbol desc
SQL
      end

      def select_10pct_gainers(most_recent_date)
        <<SQL
with last_3_days as (
select ticker_symbol, price_date, high, low, close, round((close/previous_close-1)*100, 2) as pct_change, volume, average_volume_50day, round(volume / dsp.average_volume_50day, 2) as volume_ratio, tix.float
from daily_stock_prices dsp inner join tickers tix on dsp.ticker_id=tix.id
where
price_date in (select distinct price_date from daily_stock_prices dsppd where dsppd.price_date <= '#{most_recent_date.strftime('%Y-%m-%d')}' order by dsppd.price_date desc limit 3) and
tix.scrape_data = true and
volume * 1000 * close > 5000000
order by dsp.price_date desc
)
select ticker_symbol, price_date, high, low, close, pct_change, volume, average_volume_50day as average_volume, volume_ratio, float,
round((close / (select low from last_3_days ltdpd where ltdpd.ticker_symbol=ltd.ticker_symbol order by price_date limit 1)-1)*100, 2) as pct_change_3day
from last_3_days ltd
where
ltd.price_date = (select price_date from last_3_days ltdpd where ltdpd.ticker_symbol=ltd.ticker_symbol order by price_date desc limit 1) and
ltd.close / (select low from last_3_days ltdpd where ltdpd.ticker_symbol=ltd.ticker_symbol order by price_date limit 1) > 1.10
order by ltd.close / (select low from last_3_days ltdpd where ltdpd.ticker_symbol=ltd.ticker_symbol order by price_date limit 1) desc
SQL
      end

      def select_10pct_losers(most_recent_date)
        <<SQL

with last_3_days as (
select ticker_symbol, price_date, high, low, close, round((close/previous_close-1)*100, 2) as pct_change, volume, average_volume_50day, round(volume / dsp.average_volume_50day, 2) as volume_ratio, tix.float
from daily_stock_prices dsp inner join tickers tix on dsp.ticker_id=tix.id
where
price_date in (select distinct price_date from daily_stock_prices dsppd where dsppd.price_date <= '#{most_recent_date.strftime('%Y-%m-%d')}' order by dsppd.price_date desc limit 3) and
tix.scrape_data = true and
volume * 1000 * close > 5000000
order by dsp.price_date desc
)
select ticker_symbol, price_date, high, low, close, pct_change, volume, average_volume_50day as average_volume, volume_ratio, float,
round((close / (select low from last_3_days ltdpd where ltdpd.ticker_symbol=ltd.ticker_symbol order by price_date limit 1)-1)*100, 2) as pct_change_3day
from last_3_days ltd
where
ltd.price_date = (select price_date from last_3_days ltdpd where ltdpd.ticker_symbol=ltd.ticker_symbol order by price_date desc limit 1) and
ltd.close / (select low from last_3_days ltdpd where ltdpd.ticker_symbol=ltd.ticker_symbol order by price_date limit 1) < 0.90
order by ltd.close / (select low from last_3_days ltdpd where ltdpd.ticker_symbol=ltd.ticker_symbol order by price_date limit 1) desc
SQL
      end

      def select_sma50_bear_cross(most_recent_date)
        <<SQL
with trading_days as
(
select distinct price_date from daily_stock_prices where price_date < '#{most_recent_date.strftime('%Y-%m-%d')}' order by price_date desc
)
select price_date, close, volume, ticker_symbol, sma50, close as last_trade, (round(close/previous_close, 2)-1)*100 as pct_change, average_volume_50day as average_volume, round(round(volume / 1000) / average_volume_50day, 2) as volume_ratio, float,
round(volume / average_volume_50day, 2) as volume_ratio,
round((close / (select close from daily_stock_prices dsp60 where dsp60.ticker_symbol=d.ticker_symbol and dsp60.price_date=(select price_date from trading_days offset 60 limit 1)) - 1) * 100, 2) as change_60days
from daily_stock_prices d inner join tickers t on t.id=d.ticker_id
where
t.scrape_data=true and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
volume > 1000 and
close < sma50 and
not exists (select * from daily_stock_prices dsa where dsa.ticker_symbol=d.ticker_symbol and dsa.close < dsa.sma50 and dsa.price_date < d.price_date and dsa.price_date > (select price_date from trading_days offset 15 limit 1))
order by
change_60days desc
SQL
      end

      def select_sma50_bull_cross(most_recent_date)
        <<SQL
with trading_days as
(
select distinct price_date from daily_stock_prices where price_date < '#{most_recent_date.strftime('%Y-%m-%d')}' order by price_date desc
)
select price_date, close, volume, ticker_symbol, sma50, close as last_trade, (round(close/previous_close, 2)-1)*100 as pct_change, average_volume_50day as average_volume, round(round(volume / 1000) / average_volume_50day, 2) as volume_ratio, float,
round(volume / average_volume_50day, 2) as volume_ratio,
round((close / (select close from daily_stock_prices dsp60 where dsp60.ticker_symbol=d.ticker_symbol and dsp60.price_date=(select price_date from trading_days offset 60 limit 1)) - 1) * 100, 2) as change_60days
from daily_stock_prices d inner join tickers t on t.id=d.ticker_id
where
t.scrape_data=true and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
volume > 1000 and
close > sma50 and
not exists (select * from daily_stock_prices dsa where dsa.ticker_symbol=d.ticker_symbol and dsa.close > dsa.sma50 and dsa.price_date < d.price_date and dsa.price_date > (select price_date from trading_days offset 15 limit 1))
order by
change_60days
SQL
      end

      def select_sma200_bear_cross(most_recent_date)
        <<SQL
with trading_days as
(
select distinct price_date from daily_stock_prices where price_date < '#{most_recent_date.strftime('%Y-%m-%d')}' order by price_date desc
)
select price_date, close, volume, ticker_symbol, sma200, close as last_trade, (round(close/previous_close, 2)-1)*100 as pct_change, average_volume_50day as average_volume, round(round(volume / 1000) / average_volume_50day, 2) as volume_ratio, float,
round(volume / average_volume_50day, 2) as volume_ratio,
round((close / (select close from daily_stock_prices dsp60 where dsp60.ticker_symbol=d.ticker_symbol and dsp60.price_date=(select price_date from trading_days offset 60 limit 1)) - 1) * 100, 2) as change_60days
from daily_stock_prices d inner join tickers t on t.id=d.ticker_id
where
t.scrape_data=true and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
volume > 1000 and
close < sma200 and
not exists (select * from daily_stock_prices dsa where dsa.ticker_symbol=d.ticker_symbol and dsa.close < dsa.sma200 and dsa.price_date < d.price_date and dsa.price_date > (select price_date from trading_days offset 15 limit 1))
order by
change_60days desc
SQL
      end

      def select_sma200_bull_cross(most_recent_date)
        <<SQL
with trading_days as
(
select distinct price_date from daily_stock_prices where price_date < '#{most_recent_date.strftime('%Y-%m-%d')}' order by price_date desc
)
select price_date, close, volume, ticker_symbol, sma200, close as last_trade, (round(close/previous_close, 2)-1)*100 as pct_change, average_volume_50day as average_volume, round(round(volume / 1000) / average_volume_50day, 2) as volume_ratio, float,
round(volume / average_volume_50day, 2) as volume_ratio,
round((close / (select close from daily_stock_prices dsp60 where dsp60.ticker_symbol=d.ticker_symbol and dsp60.price_date=(select price_date from trading_days offset 60 limit 1)) - 1) * 100, 2) as change_60days
from daily_stock_prices d inner join tickers t on t.id=d.ticker_id
where
t.scrape_data=true and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
volume > 1000 and
close > sma200 and
not exists (select * from daily_stock_prices dsa where dsa.ticker_symbol=d.ticker_symbol and dsa.close > dsa.sma200 and dsa.price_date < d.price_date and dsa.price_date > (select price_date from trading_days offset 15 limit 1))
order by
change_60days
SQL
      end

      def select_52week_highs(most_recent_date)
        <<SQL
with ticker_list as (
  select
  ticker_symbol, high, close, volume,
  round(close/previous_close, 2) as pct_change,
  average_volume_50day as average_volume,
  round(volume / average_volume_50day, 2) as volume_ratio,
  float
  from daily_stock_prices dsp inner join tickers tix on dsp.ticker_symbol=tix.symbol
  where price_date='#{most_recent_date.strftime('%Y-%m-%d')}' and tix.scrape_data and average_volume_50day>0
)
select
ticker_symbol,
close,
pct_change,
high,
volume,
average_volume,
volume_ratio,
float
from ticker_list
where
high=(select max(high) as high_52week from (select high from daily_stock_prices dsp52 where ticker_symbol=ticker_list.ticker_symbol and price_date<='#{most_recent_date.strftime('%Y-%m-%d')}' order by price_date desc limit 250) as high_52week_qry)
order by
volume_ratio desc and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
scrape_data=true
SQL
      end

      def select_bullish_gaps(most_recent_date)
        <<SQL
select ticker_symbol, price_date, open, high, low, close as last_trade, round(volume, 0) as volume, round(average_volume_50day, 0) as average_volume, float, round(volume / average_volume_50day, 2) as volume_ratio, snapshot_time, previous_high,
round((close / previous_high-1)*100, 2) as gap_pct
from daily_stock_prices d
inner join tickers t on d.ticker_symbol=t.symbol
where
t.scrape_data = true and
close > 1 and
volume > 100 and
low > previous_high and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
open / previous_high > 1.03
order by gap_pct desc
SQL

#         <<SQL
# select ticker_symbol, price_date, open, high, low, close as last_trade, volume, average_volume_50day as average_volume, float, round(volume / average_volume_50day, 2) as volume_ratio, snapshot_time,
# (select high from daily_stock_prices dy where dy.price_date < d.price_date and dy.ticker_symbol=d.ticker_symbol order by price_date desc limit 1) as yesterdays_high,
# round((close / (select high from daily_stock_prices dy where dy.price_date < d.price_date and dy.ticker_symbol=d.ticker_symbol order by price_date desc limit 1)-1)*100, 2) as gap_pct
# from daily_stock_prices d
# inner join tickers t on d.ticker_symbol=t.symbol
# where
# volume > 100 and
# low > (select high from daily_stock_prices dy where dy.price_date < d.price_date and dy.ticker_symbol=d.ticker_symbol order by price_date desc limit 1) and
# price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
# t.scrape_data = true and
# (t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
# open / (select high from daily_stock_prices dy where dy.price_date < d.price_date and dy.ticker_symbol=d.ticker_symbol order by price_date desc limit 1) > 1.03
# order by gap_pct desc
# SQL
      end

      def select_bearish_gaps(most_recent_date)
        <<SQL
select ticker_symbol, price_date, open, high, low, close as last_trade, volume, average_volume_50day as average_volume, float, round(volume / average_volume_50day, 2) as volume_ratio, snapshot_time, previous_low,
round((close / previous_low-1)*100, 2) as gap_pct
from daily_stock_prices d
inner join tickers t on d.ticker_symbol=t.symbol
where
high < previous_low and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
t.scrape_data = true and
volume > 100 and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
open / previous_low < 0.97
order by gap_pct
SQL

#        <<SQL
# select ticker_symbol, price_date, open, high, low, close as last_trade, volume, average_volume_50day as average_volume, float, round(volume / average_volume_50day, 2) as volume_ratio, snapshot_time,
# (select high from daily_stock_prices dy where dy.price_date < d.price_date and dy.ticker_symbol=d.ticker_symbol order by price_date desc limit 1) as yesterdays_high,
# round((close / (select low from daily_stock_prices dy where dy.price_date < d.price_date and dy.ticker_symbol=d.ticker_symbol order by price_date desc limit 1)-1)*100, 2) as gap_pct
# from daily_stock_prices d
# inner join tickers t on d.ticker_symbol=t.symbol
# where
# high < (select low from daily_stock_prices dy where dy.price_date < d.price_date and dy.ticker_symbol=d.ticker_symbol order by price_date desc limit 1) and
# price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
# t.scrape_data = true and
# volume > 100 and
# (t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
# open / (select low from daily_stock_prices dy where dy.price_date < d.price_date and dy.ticker_symbol=d.ticker_symbol order by price_date desc limit 1) < 0.97
# order by gap_pct
#SQL
      end

      def select_big_range(most_recent_date)
        <<SQL
select ticker_symbol, price_date, open, close as last_trade, high, low, previous_close, volume, round(abs(high/low-1)*100, 2) as range, average_volume_50day as average_volume, float, round(volume / average_volume_50day, 2) as volume_ratio, round((close/previous_close-1)*100, 2) as pct_change, snapshot_time
from daily_stock_prices d inner join tickers t on d.ticker_symbol=t.symbol
where price_date='#{most_recent_date.strftime('%Y-%m-%d')}' and
abs(high/low-1)*100 > 5 and
volume > 1000 and
close > 4 and
round(volume / average_volume_50day, 2) > 1
order by range desc
SQL
      end

      def select_ipo_list
        <<SQL
select ticker_symbol, min(price_date) as first_price_date, current_date - date_trunc('day', min(price_date)) as days
from daily_stock_prices d
group by ticker_symbol
having min(price_date) > '2014-01-01'
order by first_price_date desc
SQL
      end

      def select_premarket_by_percent(report_date)
        <<SQL
select
  ticker_symbol,
  last_trade,
  round(((last_trade / previous_close) - 1) * 100, 2) as pct_change,
  previous_close,
  round(volume, 0) as volume,
  round(average_volume_50day, 0) as average_volume,
  '---' as volume_ratio,
  price_date,
  p.updated_at
from premarket_prices p inner join tickers t on p.ticker_symbol=t.symbol
where
t.scrape_data and
last_trade is not null and
volume > 1 and
previous_close is not null and
average_volume_50day = 0 and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
price_date = '#{report_date.strftime('%Y-%m-%d')}'
order by pct_change desc
limit 50
SQL
      end

      def select_premarket_by_volume(report_date)
        <<SQL
select
  ticker_symbol,
  last_trade,
  round(((last_trade / previous_close) - 1) * 100, 2) as pct_change,
  previous_close,
  round(volume, 0) as volume,
  round(average_volume_50day, 0) as average_volume,
  round(volume / average_volume_50day, 2) as volume_ratio,
  price_date,
  p.updated_at
from premarket_prices p inner join tickers t on p.ticker_symbol=t.symbol
where
t.scrape_data and
last_trade is not null and
last_trade > 1 and
volume is not null and
previous_close is not null and
average_volume_50day is not null and
average_volume_50day > 0 and
(((last_trade / previous_close) - 1) * 100 < -2 or ((last_trade / previous_close) - 1) * 100 > 2) and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
price_date = '#{report_date.strftime('%Y-%m-%d')}'
order by volume_ratio desc
limit 50
SQL
      end

      def select_afterhours_by_percent(report_date)
        <<SQL
select
  ticker_symbol,
  last_trade,
  round(((last_trade / intraday_close) - 1) * 100, 2) as pct_change,
  intraday_close,
  volume,
  average_volume_50day as average_volume,
  '---' as volume_ratio,
  price_date,
  p.updated_at
from after_hours_prices p inner join tickers t on p.ticker_symbol=t.symbol
where
t.scrape_data and
last_trade is not null and
last_trade > 1 and
volume > 1 and
intraday_close is not null and
average_volume_50day = 0 and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
price_date = '#{report_date.strftime('%Y-%m-%d')}'
order by pct_change desc
limit 50
SQL
      end

      def select_afterhours_by_volume(report_date)
        <<SQL
select
  ticker_symbol,
  last_trade,
  round(((last_trade / intraday_close) - 1) * 100, 2) as pct_change,
  intraday_close,
  volume,
  average_volume_50day as average_volume,
  round(volume / average_volume_50day, 2) as volume_ratio,
  price_date,
  p.updated_at
from after_hours_prices p inner join tickers t on p.ticker_symbol=t.symbol
where
t.scrape_data and
last_trade is not null and
volume is not null and
last_trade > 1 and
intraday_close is not null and
average_volume_50day is not null and
average_volume_50day > 0 and
(((last_trade / intraday_close) - 1) * 100 < -2 or ((last_trade / intraday_close) - 1) * 100 > 2) and
(t.hide_from_reports_until is null or t.hide_from_reports_until <= current_date) and
price_date = '#{report_date.strftime('%Y-%m-%d')}'
order by volume_ratio desc
limit 50
SQL
      end

      def insert_daily_stock_prices_prepopulated_fields(prepopulate_date)
        <<SQL
insert into daily_stock_prices (ticker_id, ticker_symbol, price_date, created_at, previous_close, previous_high, previous_low, snapshot_time)
select ticker_id, ticker_symbol, '#{prepopulate_date.strftime('%Y-%m-%d')}', current_timestamp, close, high, low, '#{Time.now.to_s}'
from daily_stock_prices
where price_date=(select max(price_date) from daily_stock_prices) and
ticker_symbol not in (select ticker_symbol from daily_stock_prices where price_date='#{prepopulate_date.strftime('%Y-%m-%d')}') and
ticker_symbol in (select symbol from tickers where scrape_data=true)
SQL
      end

      def update_sma50
        <<SQL
update daily_stock_prices dsp
set sma50=round((select avg(close) from (select close from daily_stock_prices da where da.ticker_symbol=dsp.ticker_symbol and da.price_date <= dsp.price_date order by da.price_date desc limit 50) as daq), 2)
where dsp.sma50 is null or dsp.snapshot_time is not null
SQL
      end

      def update_sma200
        <<SQL
update daily_stock_prices dsp
set sma200=round((select avg(close) from (select close from daily_stock_prices da where da.ticker_symbol=dsp.ticker_symbol and da.price_date <= dsp.price_date order by da.price_date desc limit 200) as daq), 2)
where dsp.price_date > '2014-01-01' and (dsp.sma200 is null or dsp.snapshot_time is not null)
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
where price_date >= '#{begin_date.strftime('%Y-%m-%d')}' and average_volume_50day is null
SQL
      end

      def update_previous_close(begin_date=Date.new(2014,1,1))
      <<SQL
update daily_stock_prices dsp set previous_close=(select close from daily_stock_prices dspp where dspp.price_date < dsp.price_date and dspp.ticker_symbol=dsp.ticker_symbol order by dspp.price_date desc limit 1) where dsp.previous_close is null and dsp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}'
SQL
      end

      def update_previous_high(begin_date=Date.new(2014,1,1))
        <<SQL
update daily_stock_prices dsp set previous_high=(select high from daily_stock_prices dspp where dspp.price_date < dsp.price_date and dspp.ticker_symbol=dsp.ticker_symbol order by dspp.price_date desc limit 1) where dsp.previous_high is null and dsp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}'
SQL
      end

      def update_previous_low(begin_date=Date.new(2014,1,1))
        <<SQL
update daily_stock_prices dsp set previous_low=(select low from daily_stock_prices dspp where dspp.price_date < dsp.price_date and dspp.ticker_symbol=dsp.ticker_symbol order by dspp.price_date desc limit 1) where dsp.previous_low is null and dsp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}'
SQL
      end


      def update_premarket_prices_average_volume_50day(begin_date)
        raise Exception.new("No begin_date given for update_average_volume_50day query") if begin_date.nil?

        <<SQL
update premarket_prices dsp_upd set
average_volume_50day=(

with price_dates as (
select distinct price_date from daily_stock_prices order by price_date desc
)
select round(avg(volume)) from (
select id, pd.price_date, pp.ticker_symbol, coalesce(pp.volume, 0) as volume from price_dates pd left join
(
select id, ticker_symbol, price_date, volume from premarket_prices
where (ticker_symbol=dsp_upd.ticker_symbol or ticker_symbol is null)
) as pp on pd.price_date=pp.price_date
where pd.price_date<dsp_upd.price_date
order by pd.price_date desc
limit 50
) as sel_vol_range
)
where price_date >= '#{begin_date.strftime('%Y-%m-%d')}' and average_volume_50day is null
SQL

# This old query doesn't adjust the average for days where we don't have any premarket quotes, so
# many days of "0" volume were not getting counted
#         <<SQL
# update premarket_prices dsp_upd set
# average_volume_50day=(
# select round(avg(volume)) from (select id, price_date, ticker_symbol, volume from premarket_prices
# where ticker_symbol=dsp_upd.ticker_symbol and price_date<dsp_upd.price_date
# order by price_date desc
# limit 50) as sel_vol_range
# )
# where price_date >= '#{begin_date.strftime('%Y-%m-%d')}' and average_volume_50day is null
# SQL
      end

      def update_premarket_prices_previous_close(begin_date=Date.new(2014,1,1))
        <<SQL
update premarket_prices pp set previous_close=(select close from daily_stock_prices dspp where dspp.price_date < pp.price_date and dspp.ticker_symbol=pp.ticker_symbol order by dspp.price_date desc limit 1) where pp.previous_close is null and pp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}'
SQL
      end

      def update_premarket_prices_previous_high(begin_date=Date.new(2014,1,1), update_all=false)
        if update_all
          <<SQL
update premarket_prices dsp set previous_high=(select high from daily_stock_prices dspp where dspp.price_date < dsp.price_date and dspp.ticker_symbol=dsp.ticker_symbol order by dspp.price_date desc limit 1) where dsp.previous_high is null and dsp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}'
SQL
        else
          <<SQL
with phd as (
select ticker_symbol, max(price_date) as price_date
from daily_stock_prices dsp
where price_date < '#{begin_date.strftime('%Y-%m-%d')}' and high is not null
group by ticker_symbol
)
update premarket_prices pmp set previous_high=(select dsp.high from phd inner join daily_stock_prices dsp on dsp.ticker_symbol=phd.ticker_symbol and dsp.price_date=phd.price_date where phd.ticker_symbol=pmp.ticker_symbol) where pmp.previous_high is null and pmp.price_date = '#{begin_date.strftime('%Y-%m-%d')}'
select phd.ticker_symbol, phd.price_date, dsp.high from daily_stock_prices dsp inner join phd on dsp.ticker_symbol=phd.ticker_symbol and dsp.price_date=phd.price_date order by phd.ticker_symbol
SQL

        end
      end

      def update_premarket_prices_previous_low(begin_date=Date.new(2014,1,1))
        <<SQL
update premarket_prices dsp set previous_low=(select low from daily_stock_prices dspp where dspp.price_date < dsp.price_date and dspp.ticker_symbol=dsp.ticker_symbol order by dspp.price_date desc limit 1) where dsp.previous_low is null and dsp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}'
SQL
      end

      def update_afterhours_prices_average_volume_50day(begin_date)
        raise Exception.new("No begin_date given for update_average_volume_50day query") if begin_date.nil?

        <<SQL
update after_hours_prices ahp_upd set
average_volume_50day=(

with price_dates as (
select distinct price_date from daily_stock_prices order by price_date desc
)
select round(avg(volume)) from (
select id, pd.price_date, pp.ticker_symbol, coalesce(pp.volume, 0) as volume from price_dates pd left join
(
select id, ticker_symbol, price_date, volume from after_hours_prices
where (ticker_symbol=ahp_upd.ticker_symbol or ticker_symbol is null)
) as pp on pd.price_date=pp.price_date
where pd.price_date<ahp_upd.price_date
order by pd.price_date desc
limit 50
) as sel_vol_range
)
where price_date >= '#{begin_date.strftime('%Y-%m-%d')}' and average_volume_50day is null
SQL
      end

      def update_afterhours_prices_intraday_close(begin_date=Date.new(2014,1,1))
        <<SQL
update after_hours_prices ahp set intraday_close=(select close from daily_stock_prices dspp where dspp.price_date = ahp.price_date and dspp.ticker_symbol=ahp.ticker_symbol) where ahp.intraday_close is null and ahp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}';
SQL
      end

      def update_afterhours_prices_intraday_high(begin_date=Date.new(2014,1,1))
        <<SQL
update after_hours_prices ahp set intraday_high=(select high from daily_stock_prices dspp where dspp.price_date = ahp.price_date and dspp.ticker_symbol=ahp.ticker_symbol) where ahp.intraday_high is null and ahp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}';
SQL
      end

      def update_afterhours_prices_intraday_low(begin_date=Date.new(2014,1,1))
        <<SQL
update after_hours_prices ahp set intraday_low=(select low from daily_stock_prices dspp where dspp.price_date = ahp.price_date and dspp.ticker_symbol=ahp.ticker_symbol) where ahp.intraday_low is null and ahp.price_date >= '#{begin_date.strftime('%Y-%m-%d')}';
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

      def insert_daily_stock_prices_from_realtime_quotes
        <<SQL
insert into daily_stock_prices (ticker_id, ticker_symbol, price_date, open, high, low, close, volume, created_at, updated_at, snapshot_time)
select ticker_id, ticker_symbol, date(quote_time), round(open, 2), round(high, 2), round(low, 2), round(last_trade, 2), volume/1000, current_timestamp, current_timestamp, quote_time
from real_time_quotes rtq
where ticker_symbol not in (select ticker_symbol from daily_stock_prices dsp where dsp.price_date=date(rtq.quote_time))
SQL
      end

      def update_daily_stock_prices_from_realtime_quotes
        <<SQL
update daily_stock_prices as dsp
set
(open, high, low, close, volume, updated_at, snapshot_time)=
(round(rtq.open, 2), round(rtq.high, 2), round(rtq.low, 2), round(rtq.last_trade, 2), rtq.volume/1000, current_timestamp, rtq.quote_time)
from real_time_quotes rtq
where dsp.ticker_symbol=rtq.ticker_symbol and dsp.price_date=date(rtq.quote_time)
SQL
      end

      def update_reset_snapshot_flags
        <<SQL
update daily_stock_prices as dsp
set snapshot_time=null
where snapshot_time is not null
SQL
      end

    end

  end
end