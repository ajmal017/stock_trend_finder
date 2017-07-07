class AddSp500ToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :sp500, :boolean
  end
end
