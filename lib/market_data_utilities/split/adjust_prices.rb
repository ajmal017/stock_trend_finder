module MarketDataUtilities
  module Split
    class AdjustPrices
      include Verbalize::Action

      input :symbol, :as_of_date, :given_shares, :for_every_shares

      def call
        ActiveRecord::Base.connection.execute(dsp_sql)
        ActiveRecord::Base.connection.execute(pmp_sql)
        ActiveRecord::Base.connection.execute(ahp_sql)

        $stf.populate_average_volume_50day(NEW_TICKER_BEGIN_DATE)
        $stf.populate_sma50
        $stf.populate_sma200
        $stf.populate_high_52_weeks
      end

      private

      def ahp_sql
        <<SQL
UPDATE after_hours_prices 
SET 
  high=(high*#{ratio}), 
  low=(low*#{ratio}), 
  last_trade=(last_trade*#{ratio}), 
  volume=(volume/#{ratio}),
  average_volume_50day=null,
  intraday_high=null,
  intraday_low=null,
  intraday_close=null
    
WHERE ticker_symbol='#{symbol}' AND price_date < '#{as_of_date.strftime('%Y-%m-%d')}'
SQL
      end

      def dsp_sql
        <<SQL
UPDATE daily_stock_prices 
SET 
  open=(open*#{ratio}), 
  high=(high*#{ratio}), 
  low=(low*#{ratio}), 
  close=(close*#{ratio}), 
  volume=(volume/#{ratio}),
  average_volume_50day=null,
  sma50=null,
  sma200=null,
  high_52_week=null
    
WHERE ticker_symbol='#{symbol}' AND price_date < '#{as_of_date.strftime('%Y-%m-%d')}'
SQL
      end

      def pmp_sql
        <<SQL
UPDATE premarket_prices 
SET 
  high=(high*#{ratio}), 
  low=(low*#{ratio}), 
  last_trade=(last_trade*#{ratio}), 
  volume=(volume/#{ratio}),
  average_volume_50day=null,
  previous_high=null,
  previous_low=null,
  previous_close=null
    
WHERE ticker_symbol='#{symbol}' AND price_date < '#{as_of_date.strftime('%Y-%m-%d')}'
SQL
      end

      def ratio
        @ratio ||= for_every_shares.to_f / given_shares.to_f
      end

    end
  end
end