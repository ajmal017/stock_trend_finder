class CreateReportSnapshots < ActiveRecord::Migration
  def change
    create_table :report_snapshots do |t|
      t.datetime "built_at"
      t.string "report_type"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false

      t.timestamps null: false
    end
  end
end
