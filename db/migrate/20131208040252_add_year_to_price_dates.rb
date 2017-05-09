class AddYearToPriceDates < ActiveRecord::Migration
  def change
    add_column :price_dates, :year, :integer
  end
end
