StockSplit.where(adjustment_made: nil).order("ticker_id, split_date desc").each do |split|
  puts "Doing #{split.ticker.symbol} split #{split.receive_shares}:#{split.for_every_shares} #{split.split_date}"
  sql = <<SQL

update daily_stock_prices as dsp_upd
 set
	open=round(open * splits_upd.for_every_shares / splits_upd.receive_shares, 2),
	high=round(high * splits_upd.for_every_shares / splits_upd.receive_shares, 2),
	low=round(low * splits_upd.for_every_shares / splits_upd.receive_shares, 2),
	close=round(close * splits_upd.for_every_shares / splits_upd.receive_shares, 2)
from stock_splits as splits_upd
where splits_upd.id=#{split.id} and dsp_upd.price_date < splits_upd.split_date and dsp_upd.ticker_id=#{split.ticker_id}

SQL
  ActiveRecord::Base.connection.execute(sql)

  # Gotta update the adjustment made column here
  sql = "update stock_splits set adjustment_made=true where id=#{split.id}"
  ActiveRecord::Base.connection.execute(sql)
end