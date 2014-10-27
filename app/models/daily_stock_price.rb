class DailyStockPrice < ActiveRecord::Base
  belongs_to :ticker
  validates_uniqueness_of :price_date, scope: :ticker

  def self.most_recent_date
    DailyStockPrice.order(price_date: :desc).first.price_date
  end
end
