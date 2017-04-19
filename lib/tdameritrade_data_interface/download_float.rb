module TDAmeritradeDataInterface

  class YahooWebScraper
    include Capybara::DSL

    def get_float(ticker_symbol)
      url = "http://finance.yahoo.com/q/ks?s=#{ticker_symbol}+Key+Statistics"
      visit(url)
      sleep 7
      doc = Nokogiri::HTML.parse(page.html)
      headers = doc.css('td.yfnc_tablehead1')
      data = doc.css('td.yfnc_tabledata1')

      float_index = headers.map { |h| h.text }.index('Float:')
      institutional_holdings_percent_index = headers.map { |h| h.text }.index('% Held by Institutions1:')
      if float_index && institutional_holdings_percent_index
        float_value = data.map { |d| d.text }[float_index]
        float_size = float_value.slice!(-1, 1)
        case float_size
          when "K" then float_value = (float_value.to_f / 1000).round(2)
          when "M" then float_value = float_value.to_f.round(2)
          when "B" then float_value = (float_value.to_f * 1000).round(2)
          else
            puts "Couldn't find K, M or B after float value"
            return false
        end
        {
            float: float_value,
            institutional_holdings_percent: data.map { |d| d.text }[institutional_holdings_percent_index].chop.to_f
        }
      else
        puts "No Float or Institutional Holdings column found for #{ticker_symbol}"
        return false
      end
    end
  end

  def self.update_floats(new_ones_only=false)
    new_ones_only ? update_list = Ticker.watching.where(float: nil) : update_list = Ticker.watching

    count = update_list.count
    update_list.each_with_index do |t, i|
      puts "Updating #{t.symbol} (#{i+1} of #{count})"
      #sleep 60 if (i+1) % 20 == 0
      new_attributes = YahooWebScraper.new.get_float(t.symbol)
      if new_attributes
        t.update_attributes(new_attributes)
        t.save!
      end
    end
    update_list.map(&:symbol)
  end

end