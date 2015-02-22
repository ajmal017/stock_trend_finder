namespace :stock_trend_finder do

  desc "Runs the specified program for debugging"
  task :run_stock_file => :environment do
    #load File.join(Rails.root, 'lib', "import_quotes_tdameritrade.rb")
    #c = TDAmeritradeApi::Client.new
    #c.login
    #c.get_daily_price_history('AMC', '20140505')


    (Date.new(2014,1,2)..Date.new(2014,3,31)).each do |date|
      error_count=0
      while error_count < 3 && error_count != -1 # error count should be -1 on a successful download of data
        begin
          $stf.import_premarket_quotes(date: date) if $stf.is_market_day?(date)
          error_count = -1
        rescue Exception => e
          error_count += 1
          puts "Error running import_premarket quotes - #{e.message} - attempt (#{error_count})"
          sleep 60
        end
      end

    end
    puts "Updating Premarket Previous Close Cache - #{Time.now}"
    $stf.populate_premarket_previous_close Date.today

    puts "Updating Premarket Previous High Cache - #{Time.now}"
    $stf.populate_premarket_previous_high Date.today

    puts "Updating Premarket Previous Low Cache - #{Time.now}"
    $stf.populate_premarket_previous_low Date.today

    puts "Calculating Premarket Average Daily Volumes - #{Time.now}"
    $stf.populate_premarket_average_volume_50day Date.today


  end
end
