class AddVIXToVIXHistory < ActiveRecord::Migration
  def change
    add_column :vix_futures_histories, :VIX, :decimal, :precision=>6, :scale=>2
  end
end
