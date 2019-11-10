module MarketDataPull; module TDAmeritrade; module PremarketQuotes; module Calculated
  class PopulateAverageVolume50Day < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Updating premarket average_volume_50day cache for #{date}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        update premarket_prices dsp_upd 
        set
          average_volume_50day=(
            with price_dates as (
              select distinct price_date 
              from daily_stock_prices 
              order by price_date desc
            )
            select avg(volume) 
            from (
              select id, pd.price_date, pp.ticker_symbol, coalesce(pp.volume, 0) as volume 
              from price_dates pd 
              left join (
                select id, ticker_symbol, price_date, volume 
                from premarket_prices
                where (ticker_symbol=dsp_upd.ticker_symbol or ticker_symbol is null)
              ) as pp on pd.price_date=pp.price_date
              where pd.price_date<dsp_upd.price_date
              order by pd.price_date desc
              limit 50
            ) as sel_vol_range
          )
        where price_date >= '#{date.strftime('%Y-%m-%d')}' and average_volume_50day is null
      SQL
    end

  end
end; end; end; end