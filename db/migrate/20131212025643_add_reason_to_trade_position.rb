class AddReasonToTradePosition < ActiveRecord::Migration
  def change
    add_column :trade_positions, :reason, :string
  end
end
