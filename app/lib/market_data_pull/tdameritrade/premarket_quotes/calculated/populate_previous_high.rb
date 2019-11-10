module MarketDataPull; module TDAmeritrade; module PremarketQuotes; module Calculated
  class PopulatePreviousHigh < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Updating premarket previous_high cache for #{date}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        with phd as (
          select ticker_symbol, max(price_date) as price_date
          from daily_stock_prices dsp
          where price_date < '#{date.strftime('%Y-%m-%d')}' and high is not null
          group by ticker_symbol
        )
        update premarket_prices pmp 
        set 
          previous_high=(
            select dsp.high 
            from phd 
            inner join daily_stock_prices dsp on dsp.ticker_symbol=phd.ticker_symbol and dsp.price_date=phd.price_date 
            where phd.ticker_symbol=pmp.ticker_symbol
        ) 
        where pmp.previous_high is null and pmp.price_date = '#{date.strftime('%Y-%m-%d')}'
      SQL
    end

  end
end; end; end; end