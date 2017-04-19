select gu.id, gu.ticker_id, gu.ticker_symbol, gu.open_pct_of_previous_high, gu.price_date, tp.trade_date, tp.position, tp.price, tp.value, tp.reason, round(gu.high/gu.open,3) as first_day_pct_move, (close < open) as first_day_down, (low<previous_high) as first_day_gap_close,
	pct_of_last_year_close,
	concat(
		'http://finance.yahoo.com/echarts?s=',
		gu.ticker_symbol,
		'+Interactive#symbol=',
		gu.ticker_symbol,
		';range=',
		(extract (year from gu.price_date)-1),
		lpad(trim(to_char((extract (month from gu.price_date)), '99')), 2, '0'),
		lpad(trim(to_char((extract (day from gu.price_date)), '99')), 2, '0'),
		',',
		(extract (year from gu.price_date)),
		lpad(trim(to_char((extract (month from gu.price_date)), '99')), 2, '0'),
		lpad(trim(to_char((extract (day from gu.price_date)), '99')), 2, '0'),
		';compare=;indicator=split+dividend+ud+volume;charttype=candlestick;crosshair=on;ohlcvalues=1;logscale=off;source=undefined;'
	) as yahoo_chart 
from gap_ups gu inner join trade_positions tp on gu.id=tp.gap_up_id
where position='SELL'
order by gu.ticker_symbol, gu.price_date, tp.trade_date