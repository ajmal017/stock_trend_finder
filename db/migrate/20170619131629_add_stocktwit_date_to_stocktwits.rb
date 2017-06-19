class AddStocktwitDateToStocktwits < ActiveRecord::Migration
  def change
    add_column :stocktwits, :stocktwit_date, :date
    add_index :stocktwits, [:stocktwit_date]
  end
end
