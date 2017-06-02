class AddDateAddedToTickers < ActiveRecord::Migration
  def change
    remove_column :tickers, :date_removed

    add_column :tickers, :date_added, :date
    Ticker.all.each do |ticker|
      ticker.update(date_added: ticker.created_at.try(:to_date))
    end
  end
end
