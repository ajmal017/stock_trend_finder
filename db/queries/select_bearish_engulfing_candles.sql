select ticker_symbol, price_date, 1-round(dsp.close/dsp.open,2) as candlestick_range from daily_stock_prices dsp
where
dsp.open > dsp.close and
dsp.close / dsp.open < .90 and
dsp.volume * dsp.close > 5000 and
dsp.open > greatest((select open from daily_stock_prices dspo where dspo.price_date<dsp.price_date and dspo.ticker_symbol=dsp.ticker_symbol order by dspo.price_date desc limit 1),
(select close from daily_stock_prices dspo where dspo.price_date<dsp.price_date and dspo.ticker_symbol=dsp.ticker_symbol order by dspo.price_date desc limit 1)) and
dsp.close < least((select open from daily_stock_prices dspc where dspc.price_date<dsp.price_date and dspc.ticker_symbol=dsp.ticker_symbol order by dspc.price_date desc limit 1),
(select close from daily_stock_prices dspc where dspc.price_date<dsp.price_date and dspc.ticker_symbol=dsp.ticker_symbol order by dspc.price_date desc limit 1))

order by price_date desc