-- scrutinize all trades
--select *, (select close from daily_stock_prices dsp where dsp.ticker_id=gus.ticker_id and dsp.price_date>gus.close_date offset 10 limit 1) as close_10_days_later from gap_up_simulation_trades gus order by open_date;

-- by year end
select * from gap_up_simulation_trades where id in (select max(id) as id from gap_up_simulation_trades group by simulation_id)

-- daily values
--select * from gap_up_simulation_trades where id in (select max(id) as id from gap_up_simulation_trades group by simulation_id, close_date)


--select * from gap_up_simulation_trades where open_date='2011-12-31'