module MarketDataUtilities
  module ShortInterest
    module Nasdaq
      class PopulateShortInterestHistory
        include Verbalize::Action

        input :symbol, :values

        def call
          values.each do |h|
            si = ShortInterestHistory.find_by(
              ticker_symbol: symbol,
              short_interest_date: h[:settlement_date],
              source: 'nasdaq',
            )

            unless si.present?
              new_si = ShortInterestHistory.new(
                ticker_symbol: symbol,
                short_interest_date: h[:settlement_date],
                shares_short: h[:short_interest],
                short_ratio: h[:days_to_cover],
                average_volume: h[:average_volume],
                source: 'nasdaq',
              )

              # We don't have a time series of float values, so we are only going to do the latest one.
              # Note that we should have the floats updated just before running this operation for it to be accurate.
              if latest_date?(h[:settlement_date])
                t = Ticker.find(symbol)
                if t.float.present?
                  new_si.float = t.float
                  new_si.short_pct_float = new_si.shares_short / new_si.float

                  t.update(
                    short_pct_float: new_si.short_pct_float,
                    short_interest_date: h[:settlement_date],
                    short_ratio: new_si.short_ratio,
                  )
                end
              end

              new_si.save!
            end
          end
        end

        private

        def latest_date?(settlement_date)
          settlement_date == values.map { |h| h[:settlement_date] }.max
        end

      end
    end
  end
end