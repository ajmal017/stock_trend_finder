class AddWeektoGapUps < ActiveRecord::Migration
  def change
    add_column :gap_ups, :week, :integer
    add_column :gap_ups, :last_year_close, :decimal
    add_column :gap_ups, :pct_of_last_year_close, :decimal
  end
end
