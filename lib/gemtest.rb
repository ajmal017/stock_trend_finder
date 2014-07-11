#require 'tdameritrade_api'

#puts ENV['TDAMERITRADE_USER_ID']
#puts ENV['TDAMERITRADE_PASSWORD']
#puts ENV['TDAMERITRADE_SOURCE_KEY']

client = TDAmeritradeApi::Client.new
client.session_id='128459556EEA989391FBAAA5E2BF8EB4.cOr5v8xckaAXQxWmG7bn2g'
#client.login
client.get_daily_price_history('SAND')
#client.login