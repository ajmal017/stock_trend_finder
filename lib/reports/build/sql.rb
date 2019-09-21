module Reports
  module Build
    module SQL
      # The goal will be to eventually move the SQL query strings out of the TDAmeritradeDataInterface namespace and put them here
      # extend TDAmeritradeDataInterface::SQLQueryStrings

      def select_52_week_highs(most_recent_date)
        <<SQL
with ticker_list as 
(
  select
    ticker_symbol, high, close as last_trade, volume,
    (close/previous_close-1)*100 as pct_change,
    average_volume_50day as average_volume,
    volume / average_volume_50day as volume_ratio,
    float,
    case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded, 
    coalesce(t.annual_dividend_amount, 0) / close * 100 as dividend_yield,   
    high_52_week,
    (close/high_52_week-1)*100 as pct_above_52_week,
    coalesce(snapshot_time, dsp.updated_at) as snapshot_time,
    t.short_ratio as short_ratio,
    t.short_pct_float * 100 as short_percent_of_float,
    t.institutional_holdings_percent as institutional_ownership_percent,  
    t.hide_from_reports_until > current_date as gray_symbol,
    t.sp500,
    t.market_cap,
    case 
      when date_added is null then
        null
      when current_date - date_added > 365 then
            null
        else
          current_date - date_added
    end as days_active,
    high_52_week_streak as week_52_streak
  from daily_stock_prices dsp inner join tickers t on dsp.ticker_symbol=t.symbol
  where 
    price_date='#{most_recent_date.strftime('%Y-%m-%d')}' and
    volume > 20 and
    high_52_week > 0 and
    high > high_52_week and
    close > 1 and
    average_volume_50day > 0 and 
    t.scrape_data
)
select
  ticker_symbol,
  last_trade,
  pct_change as change_percent,
  volume,
  average_volume as volume_average,
  volume_ratio,
  float,
  float_percent_traded,
  dividend_yield,
  pct_above_52_week as percent_above_52_week_high,
  snapshot_time,
  short_ratio as short_days_to_cover,
  short_percent_of_float,
  institutional_ownership_percent,
  gray_symbol,
  sp500,
  market_cap,
  days_active,
  week_52_streak
from ticker_list
order by
  volume_ratio desc
SQL
      end

      def select_52_week_lows(most_recent_date)
        <<SQL
with ticker_list as 
(
  select
    ticker_symbol, high, close as last_trade, volume,
    (close/previous_close-1)*100 as pct_change,
    average_volume_50day as average_volume,
    volume / average_volume_50day as volume_ratio,
    float,
    case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded, 
    coalesce(t.annual_dividend_amount, 0) / close * 100 as dividend_yield,   
    high_52_week,
    (close/low_52_week-1)*100 as pct_below_52_week,
    coalesce(snapshot_time, dsp.updated_at) as snapshot_time,
    t.short_ratio as short_ratio,
    t.short_pct_float * 100 as short_percent_of_float,
    t.institutional_holdings_percent as institutional_ownership_percent,  
    t.hide_from_reports_until > current_date as gray_symbol,
    t.sp500,
    t.market_cap,
    case 
      when date_added is null then
        null
      when current_date - date_added > 365 then
            null
        else
          current_date - date_added
    end as days_active,
    low_52_week_streak as week_52_streak
  from daily_stock_prices dsp inner join tickers t on dsp.ticker_symbol=t.symbol
  where 
    price_date='#{most_recent_date.strftime('%Y-%m-%d')}' and
    volume > 20 and
    low_52_week > 0 and
    low < low_52_week and
    close > 1 and 
    average_volume_50day > 0 and 
    t.scrape_data
)
select
  ticker_symbol,
  last_trade,
  pct_change as change_percent,
  volume,
  average_volume as volume_average,
  volume_ratio,
  float,
  float_percent_traded,
  dividend_yield,
  pct_below_52_week as percent_below_52_week_low,
  snapshot_time,
  short_ratio as short_days_to_cover,
  short_percent_of_float,
  institutional_ownership_percent,
  gray_symbol,
  sp500,
  market_cap,
  days_active,
  week_52_streak
from ticker_list
order by
  volume_ratio desc
SQL
      end

      def select_active(most_recent_date)
        <<SQL
select
  ticker_symbol,
  price_date,
  close as last_trade,
  ((close / previous_close) - 1) * 100 as change_percent,
  volume as volume,
  average_volume_50day as volume_average,
  volume / average_volume_50day as volume_ratio,
  t.float,
  case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded,
  coalesce(t.annual_dividend_amount, 0) / close * 100 as dividend_yield,   
  coalesce(snapshot_time, d.updated_at) as snapshot_time,
  t.short_ratio as short_days_to_cover,
  t.short_pct_float * 100 as short_percent_of_float,
  t.institutional_holdings_percent as institutional_ownership_percent,
  t.hide_from_reports_until > current_date as gray_symbol,
  t.sp500

from daily_stock_prices d inner join tickers t on t.symbol=d.ticker_symbol
where
t.scrape_data=true and
abs((((close / previous_close) - 1) * 100)) > 2 and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' and
(close * volume > 5000) and
average_volume_50day > 0 
order by volume_ratio desc
limit 50
SQL
      end

      def select_after_hours_by_percent(report_date)
        <<SQL
select
  ticker_symbol,
  last_trade,
  ((last_trade / intraday_close) - 1) * 100 as change_percent,
  intraday_close,
  volume as volume,
  average_volume_50day as volume_average,
  '---' as volume_ratio,
  price_date,
  p.updated_at as snapshot_time,
  t.float,
  case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded,   
  coalesce(t.annual_dividend_amount, 0) / last_trade * 100 as dividend_yield,   
  t.short_ratio as short_days_to_cover,
  t.short_pct_float * 100 as short_percent_of_float,
  t.institutional_holdings_percent as institutional_ownership_percent,  
  t.hide_from_reports_until > current_date as gray_symbol,
  t.sp500
from after_hours_prices p inner join tickers t on p.ticker_symbol=t.symbol
where
t.scrape_data and
last_trade is not null and
last_trade > 1 and
volume > 10 and
intraday_close is not null and
average_volume_50day = 0 and
price_date = '#{report_date.strftime('%Y-%m-%d')}' and
average_volume_50day > 0 and 
((last_trade / intraday_close) - 1) * 100 > 1
order by change_percent desc
limit 50
SQL
      end

      def select_after_hours_by_volume(report_date)
        <<SQL
select
  ticker_symbol,
  last_trade,
  ((last_trade / intraday_close) - 1) * 100 as change_percent,
  intraday_close,
  volume as volume,
  average_volume_50day as volume_average,
  volume / average_volume_50day as volume_ratio,
  price_date,
  p.updated_at as snapshot_time,
  t.float,
  case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded,   
  coalesce(t.annual_dividend_amount, 0) / last_trade * 100 as dividend_yield,   
  t.short_ratio as short_days_to_cover,
  t.short_pct_float * 100 as short_percent_of_float,
  t.institutional_holdings_percent as institutional_ownership_percent,  
  t.hide_from_reports_until > current_date as gray_symbol,
  t.sp500
from after_hours_prices p inner join tickers t on p.ticker_symbol=t.symbol
where
t.scrape_data and
last_trade is not null and
volume is not null and
volume > 10 and
last_trade > 1 and
intraday_close is not null and
average_volume_50day is not null and
average_volume_50day > 0 and
(((last_trade / intraday_close) - 1) * 100 < -2 or ((last_trade / intraday_close) - 1) * 100 > 2) and
price_date = '#{report_date.strftime('%Y-%m-%d')}'
order by volume_ratio desc
limit 50
SQL
      end

      def select_gaps(most_recent_date)
      <<SQL
select
  ticker_symbol,
  price_date,
  close as last_trade,
  (close / previous_close-1)*100 as change_percent,
  volume as volume,
  average_volume_50day as volume_average,
  volume / average_volume_50day as volume_ratio,
  t.float,
  case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded,
  coalesce(t.annual_dividend_amount, 0) / close * 100 as dividend_yield,   
  coalesce(snapshot_time, d.updated_at) as snapshot_time,
  (open / previous_high-1)*100 as gap_percent,
  t.short_ratio as short_days_to_cover,
  t.short_pct_float * 100 as short_percent_of_float,
  t.institutional_holdings_percent as institutional_ownership_percent,  
  t.hide_from_reports_until > current_date as gray_symbol,
  t.sp500
from daily_stock_prices d
inner join tickers t on d.ticker_symbol=t.symbol
where
t.scrape_data = true and
close > 1 and
average_volume_50day > 0 and 
volume > 100 and
(
  (low > previous_high and open / previous_high > 1.03) or (high < previous_low and open / previous_low < 0.97)  
) and
price_date = '#{most_recent_date.strftime('%Y-%m-%d')}' 
order by volume_ratio desc
SQL
      end

      def select_premarket_by_percent(report_date)
        <<SQL
select
  ticker_symbol,
  last_trade,
  ((last_trade / previous_close) - 1) * 100 as change_percent,
  previous_close,
  volume as volume,
  average_volume_50day as volume_average,
  '---' as volume_ratio,
  t.short_ratio as short_days_to_cover,
  t.short_pct_float * 100 as short_percent_of_float,
  price_date,
  p.updated_at as snapshot_time,
  t.float,
  case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded,
  coalesce(t.annual_dividend_amount, 0) / last_trade * 100 as dividend_yield,   
  t.institutional_holdings_percent as institutional_ownership_percent,
  t.hide_from_reports_until > current_date as gray_symbol,
  t.market_cap,
  t.sp500,
  high_52_week,
  low_52_week,
  (last_trade > high_52_week) or (last_trade < low_52_week) as outside_52_week_range
from premarket_prices p inner join tickers t on p.ticker_symbol=t.symbol
where
t.scrape_data and
last_trade is not null and
volume > 8 and
previous_close is not null and
average_volume_50day = 0 and
price_date = '#{report_date.strftime('%Y-%m-%d')}'
order by change_percent desc
limit 50
SQL
      end

      def select_premarket_by_volume(report_date)
        <<SQL
select
  ticker_symbol,
  last_trade,
  ((last_trade / previous_close) - 1) * 100 as change_percent,
  previous_close,
  volume as volume,
  average_volume_50day as volume_average,
  volume / average_volume_50day as volume_ratio,
  t.short_ratio as short_days_to_cover,
  t.short_pct_float * 100 as short_percent_of_float,
  coalesce(t.annual_dividend_amount, 0) / last_trade * 100 as dividend_yield,   
  price_date,
  p.updated_at as snapshot_time,
  t.float,
  case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded,   
  coalesce(t.annual_dividend_amount, 0) / last_trade * 100 as dividend_yield,   
  t.institutional_holdings_percent as institutional_ownership_percent,
  t.hide_from_reports_until > current_date as gray_symbol,
  t.market_cap,
  t.sp500,
  high_52_week,
  low_52_week,
  (last_trade > high_52_week) or (last_trade < low_52_week) as outside_52_week_range
from premarket_prices p inner join tickers t on p.ticker_symbol=t.symbol
where
t.scrape_data and
last_trade is not null and
last_trade > 1 and
volume is not null and
volume > 8 and
previous_close is not null and
average_volume_50day is not null and
average_volume_50day > 0 and
(((last_trade / previous_close) - 1) * 100 < -2 or ((last_trade / previous_close) - 1) * 100 > 2) and
price_date = '#{report_date.strftime('%Y-%m-%d')}'
order by volume_ratio desc
SQL
      end

      def select_tickers_report
      <<SQL
select 
  id, 
  symbol, 
  company_name, 
  exchange, 
  scrape_data, 
  sector, 
  industry, 
  market_cap,
  sp500, 
  coalesce(unscrape_date, date_added, created_at, date '2013-01-01') as date_modified, 
  CASE
    WHEN coalesce(unscrape_date, date_added, created_at, date '2013-01-01')=date_added THEN 'Added'
    ELSE 'Removed'
  END as last_action,
  (select max(price_date) from daily_stock_prices where ticker_symbol=t.symbol) most_recent_price
from tickers t order by date_modified desc, symbol;
SQL
      end

    end
  end
end