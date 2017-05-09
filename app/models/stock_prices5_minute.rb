class StockPrices5Minute < ActiveRecord::Base
  def self.reset
    ActiveRecord::Base.connection.execute(
        "TRUNCATE TABLE stock_prices5_minutes"
    )
  end
end
