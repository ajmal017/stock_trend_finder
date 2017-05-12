class CreateVIXDailyHistories < ActiveRecord::Migration
  def change
    create_table :vix_daily_histories do |t|
      t.date :price_date
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.float :long_term_average

      t.timestamps null: false
    end
  end
end
