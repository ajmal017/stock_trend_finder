class AddRussell3000ToTickers < ActiveRecord::Migration
  def change
    add_column :tickers, :russell3000, :boolean
  end
end
