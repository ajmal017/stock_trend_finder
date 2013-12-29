class GapUp < ActiveRecord::Base
  belongs_to :ticker
  has_many :trade_positions
  has_many :gap_up_simulation_trades

  def self.all_cached(filter)
    Rails.cache.fetch(:gap_ups, expires_in: 4.hours) do
      case filter
        when :russell3000
          GapUp.where(ticker_id: Ticker.russell3000.pluck(:id))
        else
          GapUp.all
      end
    end
  end
end
