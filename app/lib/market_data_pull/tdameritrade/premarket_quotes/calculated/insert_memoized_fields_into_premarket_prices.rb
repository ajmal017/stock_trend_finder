module MarketDataPull; module TDAmeritrade; module PremarketQuotes; module Calculated
  class InsertMemoizedFieldsIntoPremarketPrices < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Copying Memoized Premarket Previous Close, High, Low, and Average Daily Volumes - #{Time.now}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        update premarket_prices pp
        set
          previous_high=mf.premarket_previous_high,
          previous_low=mf.premarket_previous_low,
          previous_close=mf.premarket_previous_close,
          average_volume_50day=mf.premarket_average_volume_50day
        from memoized_fields mf
        where pp.price_date='#{date.strftime('%Y-%m-%d')}' and mf.price_date=pp.price_date and mf.ticker_symbol=pp.ticker_symbol
      SQL
    end

  end
end; end; end; end