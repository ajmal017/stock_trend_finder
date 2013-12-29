file = File.open(File.join(Dir.getwd, 'lib', 'nyse.txt'))

file.each_line.map do |line|
  symbol, company_name = line.split(/\t/)
  Ticker.create(symbol: symbol, company_name: company_name, exchange: 'nyse')
end

#doc = Nokogiri::HTML(open('http://www.nyse.com/about/listed/lc_ny_name_A.html?ListedComp=All&start=1&startlist=1&item=1&firsttime=done'))
#
## Iterate through all of the <tr>'s
#doc.css('tr').each do |tr_tag|
#  # If the first <td> has class "gratop2", this is a row we want.
#  td_tags = tr_tag.css('td.gratop2')
#
#
#end

  # The first <td> is the name, the second <td> is the ticker symbol
