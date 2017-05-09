class DropUnnecessaryColumnsFromTickers < ActiveRecord::Migration
  def change
    remove_column :tickers, :djia
    remove_column :tickers, :sp500
    remove_column :tickers, :pullback_alerts
    remove_column :tickers, :russell3000
    remove_column :tickers, :category_tag
  end
end
