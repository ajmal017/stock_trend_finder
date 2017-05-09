select id, gu.ticker_id, ticker_symbol, gu.price_date as gap_up_price_date, dsp.day, dsp.price_date, dsp.open, dsp.high, dsp.low, dsp.close from gap_ups as gu inner join
(select row_number() over () as day, ticker_id, price_date, open, high, low, close from daily_stock_prices limit 10) as dsp on dsp.ticker_id=gu.ticker_id
order by gu.ticker_symbol