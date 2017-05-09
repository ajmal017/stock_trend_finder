class AddFieldsToRealTimeQuotes < ActiveRecord::Migration
  def change
    add_column :real_time_quotes, :open, :decimal
    add_column :real_time_quotes, :low, :decimal
    add_column :real_time_quotes, :high, :decimal
    rename_column :real_time_quotes, :price, :last_trade
  end
end
