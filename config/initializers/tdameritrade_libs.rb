require File.join(Rails.root, 'lib/tdameritrade_data_interface/tdameritrade_data_interface')
require File.join(Rails.root, 'lib/tdameritrade_data_interface/db_maintenance')

# This method is here to initially load the libraries at the command line, and
# it uses the 'load' method vs 'require' so that I can make minor changes to the libs without
# the need for restarting the rails console
def reload_libs!
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'tdameritrade_data_interface.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'sql_query_strings.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'import_daily_quotes.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'import_minute_quotes.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'util.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'vix.rb')
  load File.join(Rails.root, 'lib', 'market_data_utility.rb')
  load File.join(Rails.root, 'lib', 'market_data_pull', 'vix_futures_data_pull.rb')
  load File.join(Rails.root, 'lib', 'market_data_pull', 'ticker_float_data_pull.rb')
end

def tda_login!
  $c = TDAmeritradeApi::Client.new
  $c.login
end

$stf = TDAmeritradeDataInterface  # I've created the $stf variable as an alias to make it easier to access TDAmeritradeDataInterface methods on the command line
