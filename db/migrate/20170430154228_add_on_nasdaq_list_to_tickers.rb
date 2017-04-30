class AddOnNasdaqListToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :on_nasdaq_list, :boolean
  end
end
