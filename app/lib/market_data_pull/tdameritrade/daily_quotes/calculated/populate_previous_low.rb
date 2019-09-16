module MarketDataPull; module TDAmeritrade; module DailyQuotes; module Calculated
  class PopulatePreviousLow < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Updating previous_high cache for #{date}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        update daily_stock_prices dsp 
        set previous_low=(
          select low 
          from daily_stock_prices dspp 
          where dspp.price_date < dsp.price_date and dspp.ticker_symbol=dsp.ticker_symbol 
          order by dspp.price_date desc limit 1
        ) 
        where dsp.price_date='#{date.strftime('%Y-%m-%d')}' and dsp.previous_low is null
      SQL
    end

  end
end; end; end; end