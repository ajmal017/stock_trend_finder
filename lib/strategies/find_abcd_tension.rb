log = Array.new

Ticker.tracking_gap_ups.first(500).each do |ticker|
  puts "Looking at #{ticker.symbol}"
  #next if DailyStockPrice.where{(ticker_id.eq(ticker)) & price_date == '2014-02-13'}.first.close < 6

  consecutive_count=0
  last_high=0
  MinuteStockPrice.where{
    (ticker_id.eq(ticker)) & (price_time > '2014-02-13 09:30:00') & (price_time < '2014-02-13 16:00:00')
  }.order(:price_time).each do |min_bar|

    if min_bar.high == last_high
      consecutive_count += 1
    else
      consecutive_count = 0
    end
    if consecutive_count >= 5
      puts "Found #{ticker.symbol} at #{min_bar.price_time}"
      log << "Found #{ticker.symbol} at #{min_bar.price_time}"
      break
    end
    last_high = min_bar.high

  end

end

puts "Found #{log.count} instances"
log.each { |line| puts line }
