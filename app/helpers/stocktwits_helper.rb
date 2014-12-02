require 'htmlentities'

module StocktwitsHelper
  def format_stocktwits_message(message_text)
    coder = HTMLEntities.new
    coder.decode message_text
  end

  def format_ticker_nav_link(ticker)
    "#{link_to(ticker['symbol'], "#", :class=>"symbol-filter-link", "data-symbol"=>ticker['symbol'])} (#{ticker['count']}) - #{ticker['last_updated']}"
  end

end
