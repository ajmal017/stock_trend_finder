class ChangeStocktwitMessageToText < ActiveRecord::Migration
  def change
    change_column :stocktwits, :message, :text
  end
end
