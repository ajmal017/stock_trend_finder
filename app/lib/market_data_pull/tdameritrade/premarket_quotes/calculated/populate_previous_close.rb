module MarketDataPull; module TDAmeritrade; module PremarketQuotes; module Calculated
  class PopulatePreviousClose < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    input :date

    def call
      puts "Updating premarket previous_close cache for #{date}"
      ActiveRecord::Base.connection.execute query(date)
    end

    private

    def query(date)
      <<~SQL
        update premarket_prices pp 
        set previous_close=(
          select close 
          from daily_stock_prices dspp 
          where dspp.price_date < pp.price_date and dspp.ticker_symbol=pp.ticker_symbol 
          order by dspp.price_date desc 
          limit 1
        ) 
        where pp.previous_close is null and pp.price_date >= '#{date.strftime('%Y-%m-%d')}'
      SQL
    end

  end
end; end; end; end