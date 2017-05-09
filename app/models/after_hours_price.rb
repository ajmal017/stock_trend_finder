class AfterHoursPrice < ActiveRecord::Base
  def self.reset_cache
    ActiveRecord::Base.connection.execute(
        "TRUNCATE TABLE after_hours_prices"
    )
  end
end
