namespace :tickers do

  desc "Runs the daily market scanning background programs"
  task :update_company_list => :environment do
    puts "Downloading Company Lists from Nasdaq..."
    MarketDataUtilities::TickerList::DownloadNasdaqCompanyList.call

    sleep 5

    puts "Importing into tickers table..."
    report = MarketDataUtilities::TickerList::ImportNasdaqCompanyLists.(date: Date.today).value

    puts "Done!"

    puts "New Tickers:"
    report[:tickers_added].sort{|i1, i2| i1[0]<=>i2[0]}.each {|line| puts(line.join(",\t"))}

    puts "Updated Company Names:"
    report[:updated_company_names].sort{|i1, i2| i1[:symbol]<=>i2[:symbol]}.each {|line| puts(line)}

    puts "Tickers Dropped:"
    report[:tickers_dropped].sort{|i1, i2| i1[0]<=>i2[0]}.each { |line| puts(line.join(",\t"))}
  end
  
end

