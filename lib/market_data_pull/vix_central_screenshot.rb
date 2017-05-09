require 'market_data_utilities/web_scraper'

class VIXCentralScreenshot
  include WebScraper
  VIXCENTRAL_URL='http://www.vixcentral.com/'
  WAIT_TIME=7

  def download_screenshot
    start_session

    @session.visit VIXCENTRAL_URL
    sleep(WAIT_TIME)
    @session.save_screenshot(next_screenshot_path)
  ensure
    end_session
  end

  def next_screenshot_filename
    "vixcentral_#{Time.now.strftime('%Y-%m-%d_%H%M%S')}.png"
  end

  def next_screenshot_path
    File.join(STOCK_TREND_FINDER_DATA_DIR, 'vix_central_screenshots', next_screenshot_filename)
  end
end