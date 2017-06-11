class RemoveRunTimeFromRealTimeQuotes < ActiveRecord::Migration
  def change
    remove_column :real_time_quotes, :run_time
    remove_column :real_time_quotes, :ticker_id
  end
end
