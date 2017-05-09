class AddReportAndXIVToVIXFuturesHistory < ActiveRecord::Migration
  def change
    add_column :vix_futures_histories, :XIV, :decimal
    add_column :vix_futures_histories, :report_fields, :text
  end
end
