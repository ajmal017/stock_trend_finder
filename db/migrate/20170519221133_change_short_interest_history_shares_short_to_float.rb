class ChangeShortInterestHistorySharesShortToFloat < ActiveRecord::Migration
  def change
    change_column :short_interest_histories, :shares_short, :float
  end
end
