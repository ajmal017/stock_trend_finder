class AddFloatToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :float, :decimal
    add_column :tickers, :institutional_holdings_percent, :decimal
  end
end
