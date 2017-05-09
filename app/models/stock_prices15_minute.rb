class StockPrices15Minute < ActiveRecord::Base
  def self.reset
    ActiveRecord::Base.connection.execute(
        "TRUNCATE TABLE stock_prices15_minutes"
    )
  end
end
