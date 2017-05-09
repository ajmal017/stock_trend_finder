update daily_stock_prices as dsp_upd
 set
	open=round(open * splits_upd.for_every_shares / splits_upd.receive_shares, 2),
	high=round(high * splits_upd.for_every_shares / splits_upd.receive_shares, 2),
	low=round(low * splits_upd.for_every_shares / splits_upd.receive_shares, 2),
	close=round(close * splits_upd.for_every_shares / splits_upd.receive_shares, 2)
	--splits_upd.adjustment_made=true

from stock_splits as splits_upd
where splits_upd.id=461 and dsp_upd.price_date < splits_upd.split_date and dsp_upd.ticker_id=10