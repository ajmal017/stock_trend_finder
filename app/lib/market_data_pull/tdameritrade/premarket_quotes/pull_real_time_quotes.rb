# frozen_string_literal: true
module MarketDataPull; module TDAmeritrade; module PremarketQuotes
  class PullRealTimeQuotes < MarketDataPull::TDAmeritrade::TDAmeritradeAPIBase
    include Verbalize::Action

    def call
      ::MarketDataPull::TDAmeritrade::DailyQuotes::PullRealTimeQuotes.call(premarket: true)
      copy_realtime_quotes_to_premarket_prices

      puts "Copying Memoized Premarket Previous Close, High, Low, and Average Daily Volumes - #{Time.now}"
      ActiveRecord::Base.connection.execute insert_memoized_fields_into_premarket_prices(Date.current)

      Calculated::PopulateAll.call(date: Date.current)
      puts "Done"
    end

    private

    def available_real_time_quotes
      RealTimeQuote.where('quote_time > ?', Date.current).count
    end

    def copy_realtime_quotes_to_premarket_prices
      DailyStockPrice.transaction do
        puts "Inserting real time quotes into premarket stock prices #{Time.now}"
        ActiveRecord::Base.connection.execute insert_premarket_stock_prices_from_realtime_quotes
        puts "Updating real time quotes into premarket stock prices #{Time.now}"
        ActiveRecord::Base.connection.execute update_premarket_stock_prices_from_realtime_quotes
      end

    end

    def insert_memoized_fields_into_premarket_prices(date)
      <<~SQL
        update premarket_prices pp
        set
          previous_high=mf.premarket_previous_high,
          previous_low=mf.premarket_previous_low,
          previous_close=mf.premarket_previous_close,
          average_volume_50day=mf.premarket_average_volume_50day
        from memoized_fields mf
        where 
          pp.price_date='#{date.strftime('%Y-%m-%d')}' and 
          mf.price_date=pp.price_date and 
          mf.ticker_symbol=pp.ticker_symbol and
          mf.premarket_average_volume_50day is not null and
          mf.premarket_previous_high is not null and
          mf.premarket_previous_low is not null and
          mf.premarket_previous_close is not null
      SQL
    end

    def insert_premarket_stock_prices_from_realtime_quotes
      <<~SQL
        insert into premarket_prices (
          ticker_symbol, 
          price_date, 
          high, 
          low, 
          last_trade, 
          volume, 
          created_at, 
          updated_at, 
          latest_print_time
        )
        select 
          ticker_symbol, 
          date(quote_time), 
          high, 
          low, 
          last_trade, 
          volume/1000, 
          current_timestamp, 
          current_timestamp, 
          quote_time
        from real_time_quotes rtq
        where rtq.volume > 0 and ticker_symbol not in (
          select ticker_symbol from premarket_prices pp where pp.price_date=date(rtq.quote_time)
        )
      SQL
    end

    def update_premarket_stock_prices_from_realtime_quotes
      <<SQL
update premarket_prices as pp
set
(high, low, last_trade, volume, updated_at, latest_print_time)=
(rtq.high, rtq.low, rtq.last_trade, rtq.volume/1000, current_timestamp, rtq.quote_time)
from real_time_quotes rtq
where rtq.volume > 0 and pp.ticker_symbol=rtq.ticker_symbol and pp.price_date=date(rtq.quote_time)
SQL
    end

    def ticker_watch_list
      @ticker_watch_list ||= Ticker.watching.pluck(:symbol)
    end

  end
end; end; end

