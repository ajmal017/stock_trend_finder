class DailyStockPrice < ActiveRecord::Base
  belongs_to :ticker, primary_key: 'symbol', foreign_key: 'ticker_symbol'
  validates_uniqueness_of :price_date, scope: :ticker

  def self.most_recent_date
    DailyStockPrice.order(price_date: :desc).first.price_date
  end

  def self.most_recent(symbol)
    DailyStockPrice.where(ticker_symbol: symbol).order(price_date: :desc).first
  end
end
