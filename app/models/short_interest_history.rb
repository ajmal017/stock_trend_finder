class ShortInterestHistory < ActiveRecord::Base
  def self.update_short_interest(ticker, values={})
    si = ShortInterestHistory.find_by(ticker_symbol: ticker, short_interest_date: values[:short_interest_date]) ||
         ShortInterestHistory.new(ticker_symbol: ticker)
    si.update_attributes(values)

    Ticker.find_by(symbol: ticker).update_attributes(
        {
            short_interest_date: si.short_interest_date,
            short_ratio: si.short_ratio,
            short_pct_float: si.short_pct_float
        }
    )
  end
end
