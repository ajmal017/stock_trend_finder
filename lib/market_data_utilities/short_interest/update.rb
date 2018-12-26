# Can't get short interest this way due to Yahoo API deprecation. Commenting out because path could be used
# to get short interest a different way. For now waiting for TD Ameritrade data.
#
# module MarketDataUtilities
#   module ShortInterest
#     class Update
#       include Verbalize::Action
#
#       def call
#         MarketDataUtilities::ShortInterest::Yahoo::UpdateFloats.update_floats
#         MarketDataUtilities::ShortInterest::Nasdaq::ScrapeAll.call
#
#         MarketDataUtilities::ShortInterest::Yahoo::UpdateFloats.update_all_floats_and_short_ratio(symbols: ticker_symbols_not_updated_by_nasdaq)
#       end
#
#       def most_recent_short_nasdaq_interest_history_date
#         ShortInterestHistory.where(source: 'nasdaq').order(short_interest_date: :desc).last.short_interest_date
#       end
#
#       def ticker_symbols_not_updated_by_nasdaq
#         Ticker.watching.pluck(:symbol) - ShortInterestHistory.where(short_interest_date: Date.new(2017,4,28)).pluck(:ticker_symbol)
#       end
#
#     end
#   end
# end