class CreateReviewedReports < ActiveRecord::Migration
  def change
    create_table :report_reviews do |t|
      t.date :report_date
      t.string :report_type
      t.date :reviewed_date

      t.timestamps null: false
    end

    add_index "report_reviews", ["report_date", "report_type"], name: "report_reviews_unique", unique: true, using: :btree
  end
end
