class ConvertDecimalFieldsToFloat < ActiveRecord::Migration
  def up
    change_column :after_hours_prices, :volume, :float
    change_column :after_hours_prices, :average_volume_50day, :float
    change_column :after_hours_prices, :high, :float
    change_column :after_hours_prices, :low, :float
    change_column :after_hours_prices, :last_trade, :float
    change_column :after_hours_prices, :intraday_high, :float
    change_column :after_hours_prices, :intraday_low, :float
    change_column :after_hours_prices, :intraday_close, :float

    change_column :daily_stock_prices, :open, :float
    change_column :daily_stock_prices, :high, :float
    change_column :daily_stock_prices, :low, :float
    change_column :daily_stock_prices, :close, :float
    change_column :daily_stock_prices, :volume, :float
    change_column :daily_stock_prices, :previous_close, :float
    change_column :daily_stock_prices, :previous_high, :float
    change_column :daily_stock_prices, :previous_low, :float
    change_column :daily_stock_prices, :average_volume_50day, :float
    change_column :daily_stock_prices, :sma50, :float
    change_column :daily_stock_prices, :sma200, :float

    change_column :memoized_fields, :open, :float
    change_column :memoized_fields, :high, :float
    change_column :memoized_fields, :low, :float
    change_column :memoized_fields, :close, :float
    change_column :memoized_fields, :volume, :float

    change_column :premarket_prices, :last_trade, :float
    change_column :premarket_prices, :open, :float
    change_column :premarket_prices, :high, :float
    change_column :premarket_prices, :low, :float
    change_column :premarket_prices, :close, :float
    change_column :premarket_prices, :volume, :float
    change_column :premarket_prices, :previous_close, :float
    change_column :premarket_prices, :previous_high, :float
    change_column :premarket_prices, :previous_low, :float
    change_column :premarket_prices, :average_volume_50day, :float

    change_column :real_time_quotes, :last_trade, :float
    change_column :real_time_quotes, :open, :float
    change_column :real_time_quotes, :high, :float
    change_column :real_time_quotes, :low, :float
    change_column :real_time_quotes, :volume, :float

    change_column :short_interest_histories, :short_pct_float, :float
    change_column :short_interest_histories, :short_ratio, :float
    change_column :short_interest_histories, :float, :float

    change_column :tickers, :short_pct_float, :float
    change_column :tickers, :short_ratio, :float
    change_column :tickers, :float, :float
    change_column :tickers, :institutional_holdings_percent, :float
  end

  def down
    change_column :after_hours_prices, :volume, :decimal, precision: 15, scale: 2
    change_column :after_hours_prices, :average_volume_50day, :decimal, precision: 15, scale: 2
    change_column :after_hours_prices, :high, :decimal, precision: 15, scale: 2
    change_column :after_hours_prices, :low, :decimal, precision: 15, scale: 2
    change_column :after_hours_prices, :last_trade, :decimal, precision: 15, scale: 2
    change_column :after_hours_prices, :intraday_high, :decimal, precision: 15, scale: 2
    change_column :after_hours_prices, :intraday_low, :decimal, precision: 15, scale: 2
    change_column :after_hours_prices, :intraday_close, :decimal, precision: 15, scale: 2

    change_column :daily_stock_prices, :open, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :high, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :low, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :close, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :volume, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :previous_close, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :previous_high, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :previous_low, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :average_volume_50day, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :sma50, :decimal, precision: 15, scale: 2
    change_column :daily_stock_prices, :sma200, :decimal, precision: 15, scale: 2

    change_column :memoized_fields, :open, :decimal, precision: 15, scale: 2
    change_column :memoized_fields, :high, :decimal, precision: 15, scale: 2
    change_column :memoized_fields, :low, :decimal, precision: 15, scale: 2
    change_column :memoized_fields, :close, :decimal, precision: 15, scale: 2
    change_column :memoized_fields, :volume, :decimal, precision: 15, scale: 2

    change_column :premarket_prices, :last_trade, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :open, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :high, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :low, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :close, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :volume, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :previous_close, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :previous_high, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :previous_low, :decimal, precision: 15, scale: 2
    change_column :premarket_prices, :average_volume_50day, :decimal, precision: 15, scale: 2

    change_column :real_time_quotes, :last_trade, :decimal, precision: 15, scale: 2
    change_column :real_time_quotes, :open, :decimal, precision: 15, scale: 2
    change_column :real_time_quotes, :high, :decimal, precision: 15, scale: 2
    change_column :real_time_quotes, :low, :decimal, precision: 15, scale: 2
    change_column :real_time_quotes, :volume, :decimal, precision: 15, scale: 2

    change_column :short_interest_histories, :short_pct_float, :decimal, precision: 15, scale: 2
    change_column :short_interest_histories, :short_ratio, :decimal, precision: 15, scale: 2
    change_column :short_interest_histories, :float, :decimal, precision: 15, scale: 2

    change_column :tickers, :short_pct_float, :decimal, precision: 15, scale: 2
    change_column :tickers, :short_ratio, :decimal, precision: 15, scale: 2
    change_column :tickers, :float, :decimal, precision: 15, scale: 2
    change_column :tickers, :institutional_holdings_percent, :decimal, precision: 15, scale: 2
  end
end
