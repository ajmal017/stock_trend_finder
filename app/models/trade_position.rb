class TradePosition < ActiveRecord::Base
  belongs_to :gap_up
  belongs_to :ticker
end
