# frozen_string_literal: true
require File.join(Rails.root, 'lib/tdameritrade_data_interface/tdameritrade_data_interface')
require File.join(Rails.root, 'lib/tdameritrade_data_interface/db_maintenance')
require File.join(Rails.root, 'lib/autoload_libs')

def load_ticker_icon_category_list
  return $ticker_icon_categories = {} unless ActiveRecord::Base.connection.data_source_exists? 'tickers'

  biotech = Ticker.all.select(:symbol).where(industry: "Biotechnology: Electromedical & Electrotherapeutic Apparatus").pluck(:symbol)
  pharma = Ticker.all.select(:symbol).where(industry: "Major Pharmaceuticals").pluck(:symbol)

  ticker_hash = {}
  biotech.each { |symbol| ticker_hash[symbol] = 'stock-icon-biotech.png' }
  pharma.each { |symbol| ticker_hash[symbol] = 'stock-icon-majorpharma.png' }

  $ticker_icon_categories = ticker_hash
end

load_ticker_icon_category_list


# This method is here to initially load the libraries at the command line, and
# it uses the 'load' method vs 'require' so that I can make minor changes to the libs without
# the need for restarting the rails console.
#
# Note that this was built before I figured out how to use the eager_load_paths Rails setting to
# automatically add everything in lib to the path and also make it work with the console reload! command.
# I'm not ready to chance it yet since this system is lacking test coverage and I'm not sure what impact
# it would have if I were to change this load process. Will fix this and make use of eager_load_paths sometime later.
#
def reload_libs!
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'tdameritrade_data_interface.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'sql_query_strings.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'import_daily_quotes.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'import_minute_quotes.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'shortcuts.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'util.rb')
  load File.join(Rails.root, 'lib', 'tdameritrade_data_interface', 'vix.rb')
  load File.join(Rails.root, 'lib', 'market_data_utility.rb')
  load File.join(Rails.root, 'lib', 'market_data_pull', 'vix_futures_data_pull.rb')
  load File.join(Rails.root, 'lib', 'market_data_pull', 'ticker_float_data_pull.rb')
  load File.join(Rails.root, 'lib', 'market_data_utilities', 'ticker_list', 'download_nasdaq_company_list.rb')
  load File.join(Rails.root, 'lib', 'market_data_utilities', 'ticker_list', 'import_nasdaq_company_lists.rb')
  load File.join(Rails.root, 'lib', 'market_data_utilities', 'ticker_list', 'insert_line_items.rb')
  load File.join(Rails.root, 'lib', 'market_data_utilities', 'ticker_list', 'line_item_filter.rb')
  load File.join(Rails.root, 'lib', 'market_data_utilities', 'ticker_list', 'unscrape_shell_companies.rb')

  load_ticker_icon_category_list

  reload!
end

def tda_login!
  $c = TDAmeritradeApi::Client.new
  $c.login
end

$stf = TDAmeritradeDataInterface  # I've created the $stf variable as an alias to make it easier to access TDAmeritradeDataInterface methods on the command line
