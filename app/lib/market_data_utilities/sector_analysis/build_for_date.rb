module MarketDataUtilities; module SectorAnalysis
  class BuildForDate
    include Verbalize::Action

    input :date

    def call
      dsps = DailyStockPrice.where(price_date: date).joins(:ticker).includes(:ticker)
      sector_aggregation = {}
      industry_aggregation = {}
      dsps.each do |dsp|
        market_cap = market_cap_for(dsp)
        next if market_cap.nil? || market_cap == 0

        sector_aggregation[dsp.ticker.sector] = (sector_aggregation[dsp.ticker.sector] || 0) + market_cap
        industry_aggregation[dsp.ticker.industry] = (industry_aggregation[dsp.ticker.industry] || 0) + market_cap
      end

      sector_aggregation.each do |k,v|
        mcap = MarketCapAggregation.find_or_create_by(price_date: date, bucket_type: 'sector', bucket: k)
        mcap.update(market_cap: v) if mcap.market_cap != v
      end

      industry_aggregation.each do |k,v|
        mcap = MarketCapAggregation.find_or_create_by(price_date: date, bucket_type: 'industry', bucket: k)
        mcap.update(market_cap: v) if mcap.market_cap != v
      end

      populate_pct_changes
    end

    private

    def find_aggregation(list, bucket)
      list.find { |agg| agg.bucket == bucket }
    end

    def find_fundamental_history(symbol)
      fundamentals_histories.find { |fh| fh['symbol'] == symbol }
    end

    def fundamentals_histories
      @fundamentals_histories ||=
        ActiveRecord::Base.connection.execute <<~SQL
          select symbol, fh.scrape_date, fh.float
          from tickers t
          inner join fundamentals_histories fh on t.symbol=fh.ticker_symbol
          where 
            fh.scrape_date = (
              select max(scrape_date) 
              from fundamentals_histories fhsub 
              where fhsub.ticker_symbol=t.symbol and fhsub.scrape_date <= '#{date.strftime("%Y-%m-%d")}'
            );
      SQL
    end

    def market_cap_for(dsp)
      fh = find_fundamental_history(dsp.ticker_symbol)
      return nil if fh.nil? || (fh['float'].nil? && dsp.ticker.float.nil?) || dsp.close.nil?

      (fh['float'].to_i || dsp.ticker.float) * dsp.close
    end

    def populate_pct_changes
      aggregations_1_day = MarketCapAggregation.where(price_date: StockMarketDays.market_days_from(date, -1)).to_a
      aggregations_10_day = MarketCapAggregation.where(price_date: StockMarketDays.market_days_from(date, -10)).to_a
      aggregations_30_day = MarketCapAggregation.where(price_date: StockMarketDays.market_days_from(date, -30)).to_a
      aggregations_90_day = MarketCapAggregation.where(price_date: StockMarketDays.market_days_from(date, -90)).to_a

      MarketCapAggregation.where(price_date: date).to_a.map do |aggregation|
        market_cap_current = aggregation.market_cap

        market_cap_1_day = find_aggregation(aggregations_1_day, aggregation.bucket)&.market_cap
        market_cap_10_day = find_aggregation(aggregations_10_day, aggregation.bucket)&.market_cap
        market_cap_30_day = find_aggregation(aggregations_30_day, aggregation.bucket)&.market_cap
        market_cap_90_day = find_aggregation(aggregations_90_day, aggregation.bucket)&.market_cap

        aggregation.update(
          change_pct_1_day: (market_cap_1_day.present? ? (market_cap_current / market_cap_1_day - 1) * 100: nil),
          change_pct_10_day: (market_cap_10_day.present? ? (market_cap_current / market_cap_10_day - 1) * 100 : nil),
          change_pct_30_day: (market_cap_30_day.present? ? (market_cap_current / market_cap_30_day - 1) * 100: nil),
          change_pct_90_day: (market_cap_90_day.present? ? (market_cap_current / market_cap_90_day - 1) * 100 : nil)
        )
      end
    rescue ActiveRecord::StatementInvalid
      # can happen if something funky happens with the percents
      return nil
    end

  end
end; end