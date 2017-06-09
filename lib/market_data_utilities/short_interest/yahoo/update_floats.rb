# Usage:
# TickerFloatDataPull.update_all_floats_and_short_ratio(short_as_of_date: <#date>)
#
require 'ystock'

module MarketDataUtilities
  module ShortInterest
    module Yahoo
      class UpdateFloats

        def self.calculate_short_as_of_date
          today=Date.today
          if today.day < 16
            Date.new(today.year, today.month, 15) - 1.month
          else
            Date.new(today.year, today.month, -1) - 1.month
          end
        end

        def self.call(short_as_of_date=nil)
          update_all_floats_and_short_ratio(short_as_of_date: short_as_of_date || calculate_short_as_of_date)
        end

        def self.update_all_floats_and_short_ratio(short_as_of_date: calculate_short_as_of_date, symbols: tickers)
          ticker_list = symbols || Ticker.watching.pluck(:symbol)

          ticker_list.each_slice(200) do |tickers|
            quotes = Ystock.quote(tickers)
            quotes.each do |q|
              float = 0
              unless q[:float].nil? || q[:float] =~ /N\/A/
                float = q[:float].to_f
                float = float / 1000 if float > 0

                Ticker.update(Ticker.find_by(symbol: q[:symbol]), float: float)
              end

              unless q[:short_ratio].nil? || BigDecimal.new(q[:short_ratio])==0
                dsp = DailyStockPrice.where(ticker_symbol: q[:symbol]).where('price_date >= ?', short_as_of_date).order(:price_date).first
                if dsp.present? && dsp.average_volume_50day.present?
                  shares_short = BigDecimal.new(q[:short_ratio]) * dsp.average_volume_50day
                  short_pct_float = shares_short / float if float > 0
                end
                puts short_pct_float
                ShortInterestHistory.update_short_interest(
                  q[:symbol],
                  short_ratio: q[:short_ratio],
                  short_pct_float: short_pct_float,
                  shares_short: shares_short,
                  short_interest_date: short_as_of_date,
                  float: float,
                  source: 'yahoo',
                )
              end
            end
          end
        end

        # Don't need to use this if calling update_all_floats_and_short_ratio
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
    end
  end
end
