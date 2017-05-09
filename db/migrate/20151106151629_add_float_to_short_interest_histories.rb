class AddFloatToShortInterestHistories < ActiveRecord::Migration
  def change
    add_column :short_interest_histories, :float, :decimal
  end
end
