require 'ystock'

class TickerFloatDataPull
  def self.update_all_floats_and_short_ratio(short_as_of_date: Date.today)
    Ticker.watching.pluck(:symbol).each_slice(200) do |tickers|
      quotes = Ystock.quote(tickers)
      quotes.each do |q|
        float = 0
        unless q[:float].nil? || q[:float] =~ /N\/A/
          float = BigDecimal(q[:float])
          float = float / 1000 if float > 0

          Ticker.update(Ticker.find_by(symbol: q[:symbol]), float: float)
        end

        unless q[:short_ratio].nil? || BigDecimal.new(q[:short_ratio])==0
            dsp = DailyStockPrice.try(:find_by, ticker_symbol: q[:symbol], price_date: short_as_of_date)
          if dsp.present? && dsp.average_volume_50day.present?
            shares_short = BigDecimal.new(q[:short_ratio]) * dsp.average_volume_50day
            short_pct_float = shares_short / float if float > 0
          end

          ShortInterestHistory.update_short_interest(
              q[:symbol],
              short_ratio: q[:short_ratio],
              short_pct_float: short_pct_float,
              shares_short: shares_short,
              short_interest_date: short_as_of_date,
              float: float
          )
        end
      end
    end
  end

  def self.update_floats
    Ticker.watching.pluck(:symbol).each_slice(200) do |tickers|
      quotes = Ystock.quote(tickers)
      quotes.each do |q|
        float = 0
        unless q[:float].nil? || q[:float] =~ /N\/A/
          float = BigDecimal(q[:float])
          float = float / 1000 if float > 0

          Ticker.update(Ticker.find_by(symbol: q[:symbol]), float: float)
        end
      end
    end
  end
end