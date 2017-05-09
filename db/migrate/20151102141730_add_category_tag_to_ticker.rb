class AddCategoryTagToTicker < ActiveRecord::Migration
  def change
    add_column :tickers, :category_tag, :integer
  end
end
