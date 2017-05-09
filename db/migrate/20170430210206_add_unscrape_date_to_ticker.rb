class AddUnscrapeDateToTicker < ActiveRecord::Migration
  def change
    add_column :tickers, :unscrape_date, :date
  end
end
