class DailyStockPrice < ActiveRecord::Base
  belongs_to :ticker
  validates_uniqueness_of :price_date, scope: :ticker

  def self.all_cached(filter)
    Rails.cache.fetch(:daily_stock_prices, expires_in: 4.hours) do
      case filter
        when :russell3000
          DailyStockPrice.where(ticker_id: Ticker.russell3000.pluck(:id))
        else
          DailyStockPrice.all
      end
    end
  end
end
