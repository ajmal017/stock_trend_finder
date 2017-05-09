class AddUserToStocktwits < ActiveRecord::Migration
  def change
    add_column :stocktwits, :stocktwits_user_name, :string
  end
end
