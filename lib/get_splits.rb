#text_snippet = '<center style="border-bottom:1px solid #A1A1A1; margin-bottom:5px; padding-bottom:5px;">Splits:
#    <nobr>Jul 26, 1976 [3:2]</nobr>, <nobr>Sep 6, 1994 [2:1]</nobr>, <nobr>Jul 14, 1997 [2:1]</nobr>, <nobr>Jul 14, 2005 [2:1]</nobr></center>'


require 'open-uri'

Ticker.watching.each do |ticker|
  begin
    file = open("http://finance.yahoo.com/q/ta?s=#{ticker.symbol}&t=my&l=on&z=l&q=l&p=&a=&c=")
    file.read.scan(/<nobr>(.+?)<\/nobr>/).each do |match|
      puts match
      pattern1 = Regexp.new(/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s(\d{1,2}),\s(\d{4})\s\[(\d+):(\d+)\]/)
      if match[0].match(pattern1) then
        month, day, year, receive, for_every = match[0].scan(pattern1)[0]
        puts "#{ticker.symbol} (#{ticker.id}): #{month} #{day}, #{year}, #{receive}:#{for_every}"
        StockSplit.create(ticker: ticker, split_date: Date.parse("#{year}-#{month}-#{day}"), receive_shares: receive, for_every_shares: for_every)
      else
        year, month, day, receive, for_every = match[0].scan(/(\d{4})-(\d{1,2})-(\d{1,2}) \[(\d+):(\d+)\]/)[0]
        puts "#{ticker.symbol} (#{ticker.id}): #{month} #{day}, #{year}, #{receive}:#{for_every}"
        StockSplit.create(ticker: ticker, split_date: Date.new(year.to_i, month.to_i, day.to_i), receive_shares: receive, for_every_shares: for_every)
      end
    end
  rescue
    puts "Error downloading URI for #{ticker.symbol}"
  end
end


