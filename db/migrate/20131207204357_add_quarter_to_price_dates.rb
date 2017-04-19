class AddQuarterToPriceDates < ActiveRecord::Migration
  def change
    add_column :price_dates, :quarter, :string
  end
end
