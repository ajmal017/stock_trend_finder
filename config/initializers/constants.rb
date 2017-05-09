NEW_TICKER_BEGIN_DATE=Date.new(2013,10,1)

MARKET_DAYS_FILE=File.join(Dir.pwd, 'lib', 'market_days.csv')
STOCK_TREND_FINDER_DATA_DIR = ENV['STOCK_TREND_FINDER_DATA_DIR'] || '/Users/wkotzan/Development/stock_trend_finder_data/'
NOTE_TAKER_SCREENSHOTS_DIR = File.join(Rails.root, 'public', 'local_note_taker_screenshots')

DEFAULT_SCRAPER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36'

