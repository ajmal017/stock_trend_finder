class MarketCapAggregation < ActiveRecord::Base

  enum bucket_type: {
    sector: 'sector',
    industry: 'industry'
  }

  def self.build_aggregation(date)
    dsps = DailyStockPrice.where(price_date: date).joins(:ticker)
    sector_aggregation = {}
    industry_aggregation = {}
    dsps.each do |dsp|
      market_cap = (FundamentalsHistory.as_of(dsp.ticker_symbol, date)&.float || dsp.ticker.float).try(:*, (dsp.close || 0))
      next if market_cap.nil? || market_cap == 0

      sector_aggregation[dsp.ticker.sector] = (sector_aggregation[dsp.ticker.sector] || 0) + market_cap
      industry_aggregation[dsp.ticker.industry] = (industry_aggregation[dsp.ticker.industry] || 0) + market_cap
    end

    [
      sector_aggregation.map do |k,v|
        MarketCapAggregation.create(price_date: date, bucket_type: 'sector', bucket: k, market_cap: v)
      end,
      industry_aggregation.map do |k,v|
        MarketCapAggregation.create(price_date: date, bucket_type: 'industry', bucket: k, market_cap: v)
      end
    ]

  end

end
