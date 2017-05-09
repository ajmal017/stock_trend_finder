update daily_stock_prices as dsp_upd set open_higher_than_previous_day_high=(dsp_upd.open>dsp_upd.previous_high)
--where dsp_upd.ticker_id=7000