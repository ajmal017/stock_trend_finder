namespace :stock_trend_finder do

  desc "Runs the specified program for debugging"
  task :run_stock_file => :environment do
    #load File.join(Rails.root, 'lib', "import_quotes_tdameritrade.rb")
    #c = TDAmeritradeApi::Client.new
    #c.login
    #c.get_daily_price_history('AMC', '20140505')


    $stf.update_floats(true)

  end
end
