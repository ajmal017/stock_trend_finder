require 'ystock'

class TickerFloatDataPull
  def self.update_all_floats_and_short_ratio(short_as_of_date: Date.today)
    Ticker.all.pluck(:symbol).each_slice(200) do |tickers|
      quotes = Ystock.quote(tickers)
      quotes.each do |q|
        unless q[:float].nil?
          float = BigDecimal(q[:float])
          float = float / 1000000 if float > 0

          Ticker.update(Ticker.find_by(symbol: q[:symbol]), float: float)
        end

        unless q[:short_ratio].nil?
           ShortInterestHistory.update_short_interest(q[:symbol], short_ratio: q[:short_ratio], as_of_date: short_as_of_date)
        end
      end
    end
  end
end