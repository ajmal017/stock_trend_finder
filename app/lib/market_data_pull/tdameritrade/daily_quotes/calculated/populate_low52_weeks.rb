module MarketDataPull; module TDAmeritrade; module DailyQuotes; module Calculated
  class PopulateLow52Weeks < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Updating 52 week low cache for #{date}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        update daily_stock_prices dsp_upd 
        set low_52_week=(
          select min(low) 
          from daily_stock_prices dsp 
          where dsp.ticker_symbol=dsp_upd.ticker_symbol and dsp.price_date >= (dsp_upd.price_date - interval '1 year') and dsp.price_date < dsp_upd.price_date
        )
        where price_date='#{date.strftime('%Y-%m-%d')}' and low_52_week is null
      SQL
    end

  end
end; end; end; end