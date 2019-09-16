module MarketDataPull; module TDAmeritrade; module DailyQuotes; module Calculated
  class PopulateAverageVolume50Day < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Updating average_volume_50day cache for #{date}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        update daily_stock_prices dsp_upd set
        average_volume_50day=(
          select avg(volume) from (
            select id, price_date, ticker_symbol, volume 
            from daily_stock_prices
            where ticker_symbol=dsp_upd.ticker_symbol and price_date<dsp_upd.price_date
            order by price_date desc
            limit 50
          ) as sel_vol_range
        )
        where price_date='#{date.strftime('%Y-%m-%d')}' and average_volume_50day is null
      SQL
    end

  end
end; end; end; end