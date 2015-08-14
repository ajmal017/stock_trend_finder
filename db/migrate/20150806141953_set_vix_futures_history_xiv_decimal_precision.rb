class SetVIXFuturesHistoryXIVDecimalPrecision < ActiveRecord::Migration
  def change
    change_column :vix_futures_histories, :XIV, :decimal, :precision=>15, :scale=>2
  end
end
