# require Rails.root.join('app/lib/market_data_pull/tdameritrade/daily_quotes/calculated/populate_high_52_weeks')
# load 'populate_low_52_weeks'
# load 'populate_average_volume_50_day'
# load 'populate_sma50'
# load 'populate_sma200'

module MarketDataPull; module TDAmeritrade; module DailyQuotes; module Calculated
  class PopulateAll < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      dates = if date.kind_of?(Date)
       [date]
      elsif date.kind_of?(Range)
        date
      elsif date.kind_of?(Array)
        date.sort
      else
        raise ArgumentError, 'date must be a Date, Range, or Array of Date'
      end

      dates.each do |d|
        PopulatePreviousClose.call(date: d)
        PopulatePreviousHigh.call(date: d)
        PopulatePreviousLow.call(date: d)
        PopulateHigh52Weeks.call(date: d)
        PopulateLow52Weeks.call(date: d)
        PopulateLow52Weeks.call(date: d)
        PopulateAverageVolume50Day.call(date: d)
        PopulateSma50.call(date: d)
        PopulateSma200.call(date: d)
      end
    end

  end
end; end; end; end