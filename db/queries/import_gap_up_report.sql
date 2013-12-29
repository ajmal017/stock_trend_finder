update tickers set track_gap_up=false where symbol in ('ABB')
--COPY gap_ups (ticker_id, ticker_symbol, price_date, open, high, low, close, previous_close, previous_high, previous_low, open_pct_of_previous_high)
--              FROM '/Users/wkotzan/Google Drive/Development/sites/stock_trend_finder/lib/gap_report_input_01.csv'
--              WITH (FORMAT 'csv', HEADER)