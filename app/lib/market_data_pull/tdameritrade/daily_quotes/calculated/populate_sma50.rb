module MarketDataPull; module TDAmeritrade; module DailyQuotes; module Calculated
  class PopulateSma50 < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Updating 50 SMA cache for #{date}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        update daily_stock_prices dsp
        set sma50=(
          select avg(close) 
          from (
            select close 
            from daily_stock_prices da 
            where da.ticker_symbol=dsp.ticker_symbol and da.price_date <= dsp.price_date 
            order by da.price_date desc 
            limit 50
          ) as daq)
        where dsp.price_date='#{date.strftime('%Y-%m-%d')}' and (dsp.sma50 is null)
      SQL
    end

  end
end; end; end; end