module Reports
  module Build
    module SQL
      # The goal will be to eventually move the SQL query strings out of the TDAmeritradeDataInterface namespace and put them here
      # extend TDAmeritradeDataInterface::SQLQueryStrings

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
  t.institutional_holdings_percent as institutional_ownership_percent,
  t.hide_from_reports_until > current_date as gray_symbol
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
  price_date,
  p.updated_at as snapshot_time,
  t.float,
  case when volume > 0 and t.float > 0 then volume / t.float * 100 end as float_percent_traded,   
  t.institutional_holdings_percent as institutional_ownership_percent,
  t.hide_from_reports_until > current_date as gray_symbol
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

    end
  end
end