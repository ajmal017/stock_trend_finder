require 'pry'

namespace :tickers do

  desc "Runs the daily market scanning background programs"
  task :update_company_list => :environment do
    puts "Downloading Company Lists from Nasdaq..."
    MarketDataUtilities::TickerList::DownloadNasdaqCompanyList.call

    sleep 5

    puts "Importing into tickers table..."
    report = MarketDataUtilities::TickerList::ImportNasdaqCompanyLists.(date: Date.today).value
    MarketDataUtilities::TickerList::UnscrapeShellCompanies.call

    puts "Done!"

    puts "New Tickers:"
    report[:tickers_added].sort{|i1, i2| i1[0]<=>i2[0]}.each {|line| puts(line.join(",\t"))}

    puts "Updated Company Names:"
    report[:updated_company_names].sort{|i1, i2| i1[:symbol]<=>i2[:symbol]}.each {|line| puts(line)}

    puts "Tickers Dropped:"
    report[:tickers_dropped].sort{|i1, i2| i1[0]<=>i2[0]}.each { |line| puts(line.join(",\t"))}
  end

  desc "Displays a report of changed tickers"
  task :changed_report, [:days_back] => :environment do |_task, args|
    days_back = args[:days_back] || 10
    changes = TickerChange.where('created_at >= ?', days_back.days.ago).order(:ticker_symbol)
    report = ''

    report << "Tickers Added:\n"
    changes.select { |tc| tc.type == 'add' }.map do |tc|
      report << "#{tc.action_date} #{tc.ticker_symbol}, #{Ticker.find_by(symbol: tc.ticker_symbol)&.company_name}\n"
    end

    report << "Tickers Removed:\n"
    changes.select { |tc| tc.type == 'remove' }.map do |tc|
      report << "#{tc.action_date} #{tc.ticker_symbol}, #{Ticker.find_by(symbol: tc.ticker_symbol)&.company_name}\n"
    end

    report << "Tickers Name Changed:\n"
    changes.select { |tc| tc.type == 'change_name' }.map do |tc|
      report << "#{tc.action_date} #{tc.ticker_symbol}, #{tc.old_value} -> #{tc.new_value}\n"
    end

    report << "SP500 Index Changes:\n"
    changes.select { |tc| tc.type == 'sp500_index' }.map do |tc|
      change = tc.old_value == 'f' ? "ADDED" : "REMOVED"
      report << "#{tc.action_date} #{tc.ticker_symbol}, #{Ticker.find_by(symbol: tc.ticker_symbol)&.company_name} -> #{change}\n"
    end

    puts report
  end
  
end

