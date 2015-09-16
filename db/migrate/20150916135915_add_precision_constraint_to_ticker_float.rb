class AddPrecisionConstraintToTickerFloat < ActiveRecord::Migration
  def change
    change_column :tickers, :float, :decimal, :precision => 15, :scale => 2
  end
end
