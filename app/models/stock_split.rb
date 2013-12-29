class StockSplit < ActiveRecord::Base
  belongs_to :ticker
  validates_uniqueness_of :split_date, scope: :ticker_id

  def self.all_cached
    Rails.cache.fetch(:stock_splits, expires_in: 4.hours) do
      StockSplit.all
    end
  end

end
