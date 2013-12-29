trading_days = PriceDate.all

Ticker.all.each do |t|
  prices = t.daily_stock_prices.pluck(:price_date, )
end