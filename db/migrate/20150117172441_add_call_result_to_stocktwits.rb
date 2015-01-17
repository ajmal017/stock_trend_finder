class AddCallResultToStocktwits < ActiveRecord::Migration
  def change
    add_column :stocktwits, :call_result, :integer
  end
end
