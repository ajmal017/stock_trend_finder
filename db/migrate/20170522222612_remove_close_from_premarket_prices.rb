class RemoveCloseFromPremarketPrices < ActiveRecord::Migration
  def change
    remove_column :premarket_prices, :close
  end
end
