class AddStocktwitIdToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :stocktwit_id, :integer
  end
end
