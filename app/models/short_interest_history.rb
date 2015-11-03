class ShortInterestHistory < ActiveRecord::Base
  def self.update_short_interest(ticker, values={})
    si = self.new(ticker_symbol: ticker)
    si.update_attributes(values)

    Ticker.find_by(symbol: ticker).update_attributes(
        {
            short_interest_date: si.as_of_date,
            short_ratio: si.short_ratio,
            short_pct_float: si.shares_short_pct_float
        }
    )
  end
end
