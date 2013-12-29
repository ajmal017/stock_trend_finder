class GapUpSimulationTrade < ActiveRecord::Base
  belongs_to :ticker
  belongs_to :gap_up
end
