class AddWeek52StreakToReportSnapshotLineItems < ActiveRecord::Migration
  def change
    add_column :report_snapshot_line_items, :market_cap, :decimal
    add_column :report_snapshot_line_items, :week_52_streak, :integer
    add_column :report_snapshot_line_items, :days_active, :integer
    add_column :report_snapshot_line_items, :sector, :string
    add_column :report_snapshot_line_items, :industry, :string
  end
end
