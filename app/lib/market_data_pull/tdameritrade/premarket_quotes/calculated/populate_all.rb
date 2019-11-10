module MarketDataPull; module TDAmeritrade; module PremarketQuotes; module Calculated
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
        PopulateAverageVolume50Day.call(date: d)
      end
    end

  end
end; end; end; end