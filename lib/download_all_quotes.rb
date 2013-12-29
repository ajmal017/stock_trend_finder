require 'open-uri'

Ticker.watching.each do |ticker|
  puts "Getting #{ticker.symbol}"
  ticker.download_real_time_quote(true, 'noon')
end