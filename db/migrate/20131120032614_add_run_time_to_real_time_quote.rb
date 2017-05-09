class AddRunTimeToRealTimeQuote < ActiveRecord::Migration
  def change
    add_column :real_time_quotes, :run_time, :string
  end
end
