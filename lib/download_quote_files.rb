require 'open-uri'

puts open(
         #"http://ichart.finance.yahoo.com/table.csv?s=#{ticker.symbol}&d=9&e=28&f=2013&g=d&a=0&b=2&c=1962&ignore=.csv"
         "http://www.google.com/finance/historical?q=MSFT&startdate=1%2F1%2F80&enddate=Nov+8%2C+2013&output=csv"
     ).read.encode('ASCII-8BIT')

Ticker.watching.each do |ticker|
  puts "Downloading #{ticker.symbol}..."
  begin
  download_file = open(File.join(Dir.getwd, 'downloads', "#{ticker.symbol}_prices_googlefinance.csv"), 'w:ASCII-8BIT')
  download_file.write(open(
        #"http://ichart.finance.yahoo.com/table.csv?s=#{ticker.symbol}&d=9&e=28&f=2013&g=d&a=0&b=2&c=1962&ignore=.csv"
      "http://www.google.com/finance/historical?q=#{ticker.symbol}&startdate=1%2F1%2F80&enddate=Nov+8%2C+2013&output=csv"
      ).read)
  download_file.close
  rescue
    puts "Error occurred"
  end

end

# How to copy splits
#<center style="border-bottom:1px solid #A1A1A1; margin-bottom:5px; padding-bottom:5px;">Splits:
#    <nobr>Jul 26, 1976 [3:2]</nobr>, <nobr>Sep 6, 1994 [2:1]</nobr>, <nobr>Jul 14, 1997 [2:1]</nobr>, <nobr>Jul 14, 2005 [2:1]</nobr></center>


#class YahooFinanceInterface
#
#  def self.test_method
#    puts "this is a class method"
#  end
#
#end

# Google Finance
#https://www.google.com/finance/historical?cid=661624&startdate=8%2F1%2F1982&enddate=8%2F30%2F1982&num=30&ei=02d8Uvi0C4SwqgHORg
#http://www.google.com/finance/historical?cid=661624&startdate=8%2F1%2F1982&enddate=8%2F30%2F1982&num=30&ei=02d8Uvi0C4SwqgHORg&output=csv

#https://www.google.com/finance/historical?q=NYSE%3AFDX&startdate=1%2F1%2F13&enddate=Nov+8%2C+2013&num=50
#http://www.google.com/finance/historical?q=NYSE%3AFDX&startdate=1%2F1%2F13&enddate=Nov+8%2C+2013&num=50&output=csv