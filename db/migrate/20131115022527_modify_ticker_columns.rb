class ModifyTickerColumns < ActiveRecord::Migration
  def change
    rename_column :tickers, :watch, :scrape_data
    add_column :tickers, :industry, :string
    add_column :tickers, :market_cap, :decimal
    add_column :tickers, :djia, :boolean
    add_column :tickers, :sp500, :boolean
    add_column :tickers, :track_gap_up, :boolean
    add_column :tickers, :pullback_alerts, :boolean
  end
end
