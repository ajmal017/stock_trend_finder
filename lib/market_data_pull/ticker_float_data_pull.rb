require 'ystock'

class TickerFloatDataPull
  def self.update_all_floats
    Ticker.all.pluck(:symbol).each_slice(200) do |tickers|
      quotes = Ystock.quote(tickers)
      quotes.each do |q|
        next if q[:float].nil?
        float = BigDecimal(q[:float])
        float = float / 1000000 if float > 0

        Ticker.update(Ticker.find_by(symbol: q[:symbol]), float: float)
      end
    end
  end
end