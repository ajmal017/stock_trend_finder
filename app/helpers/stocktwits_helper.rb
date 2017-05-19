require 'htmlentities'

module StocktwitsHelper

  def format_setup_nav_link(setup)
    "#{link_to(setup[0], "#", :class=>"setup-filter-link", "data-setup"=>setup[0])} (#{setup[1]})"
  end

  def format_stocktwits_message(message_text)
    format_links(message_text)
  end

  def format_ticker_nav_link(ticker)
    last_updated = ticker['last_updated'] == '00:00:00' ? 'Today' : ticker['last_updated']
    watching_icon = ticker['watching']=='t' ? "\u2606" : ''
    "#{link_to(ticker['ticker_symbol'], "#", :class=>"symbol-filter-link", "data-symbol"=>ticker['ticker_symbol'])} #{watching_icon}(#{ticker['count']}) - #{last_updated}"
  end

  def message_call_result_class(call)
    case call
      when 'correct'
        "message-call-result-correct"
      when 'incorrect'
        "message-call-result-incorrect"
      when 'no_call'
        "message-call-result-no-call"
      when 'partial'
        "message-call-result-partial"
      else
        ""
    end
  end

  private


  def convert_links(s)
    # convert link text to links
    m = s.match /\bhttp:\/\/.*\b/
    if m
      s.sub(m[0], link_to(m[0], m[0], target: "_blank"))
    else
      s
    end

    # convert ticker symbols to links
    m = s.match /^\$*[A-Z]+/
    if m
      symbol = m[0].gsub('$', '')
      s.sub(m[0], link_to(m[0], "#", class: 'no-decoration symbol-filter-link', 'data-symbol'=>m[0]))
    else
      s
    end
  end

  def format_links(message_text)
    coder = HTMLEntities.new
    raw(convert_links(coder.decode(message_text)))
  end

end
