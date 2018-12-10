class CreateReportSnapshotLineItems < ActiveRecord::Migration
  def change
    create_table :report_snapshot_line_items do |t|
      t.integer "report_snapshot_id"
      t.datetime "snapshot_time"
      t.string "ticker_symbol"
      t.float "last_trade"
      t.float "change_percent"
      t.float "volume"
      t.float "volume_average"
      t.float "volume_ratio"
      t.float "short_days_to_cover"
      t.float "short_percent_of_float"
      t.float "float"
      t.float "float_percent_traded"
      t.float "dividend_yield"
      t.float "institutional_ownership_percent"
      t.float "volume_average_premarket"
      t.float "volume_ratio_premarket"
      t.float "gap_percent"
      t.float "percent_above_52_week_high"
      t.float "percent_below_52_week_low"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["report_snapshot_id", "ticker_symbol"], name: "report_line_items_unique", unique: true

      t.timestamps null: false
    end
  end
end
