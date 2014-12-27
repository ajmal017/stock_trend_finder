require 'htmlentities'

module StocktwitsHelper
  def format_stocktwits_message(message_text)
    coder = HTMLEntities.new
    raw(convert_links(coder.decode(message_text)))
  end

  def format_ticker_nav_link(ticker)
    last_updated = ticker['last_updated'] == '00:00:00' ? 'Today' : ticker['last_updated']
    "#{link_to(ticker['symbol'], "#", :class=>"symbol-filter-link", "data-symbol"=>ticker['symbol'])} (#{ticker['count']}) - #{last_updated}"
  end

private
  def convert_links(s)
    m = s.match /\bhttp:\/\/.*\b/
    if m
      s.sub(m[0], link_to(m[0], m[0], target: "_blank"))
    else
      s
    end
  end

end
