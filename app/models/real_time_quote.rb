class RealTimeQuote < ActiveRecord::Base
  belongs_to :ticker

  def self.reset_cache
    ActiveRecord::Base.connection.execute(
        "TRUNCATE TABLE real_time_quotes"
    )
  end
end
