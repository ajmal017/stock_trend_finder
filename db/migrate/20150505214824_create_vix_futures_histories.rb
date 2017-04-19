class CreateVIXFuturesHistories < ActiveRecord::Migration
  def change
    create_table :vix_futures_histories do |t|
      t.datetime :snapshot_time
      t.decimal :contango_percent, :precision=>5, :scale=>2
      t.text :futures_curve

      t.timestamps null: false
    end
  end
end
