module MarketDataPull; module TDAmeritrade; module DailyQuotes; module Calculated
  class PopulateHigh52Weeks < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Updating 52 week high cache for #{date}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        update daily_stock_prices dsp_upd 
        set high_52_week=(
          select max(high) 
          from daily_stock_prices dsp_high 
          where dsp_high.ticker_symbol=dsp_upd.ticker_symbol and dsp_high.price_date >= (dsp_upd.price_date - interval '1 year') and dsp_high.price_date < dsp_upd.price_date
        )
        where price_date='#{date.strftime('%Y-%m-%d')}' and high_52_week is null
      SQL
    end

  end
end; end; end; end