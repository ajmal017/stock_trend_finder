class AddShortInterestToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :short_interest_date, :date
    add_column :tickers, :short_ratio, :decimal, precision: 15, scale: 3
    add_column :tickers, :short_pct_float, :decimal, precision: 15, scale: 3
  end
end
