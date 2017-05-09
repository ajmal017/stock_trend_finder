class RemovePriceGap < ActiveRecord::Migration
  def change
    drop_table :price_gaps
  end
end
