class CreateTickerChanges < ActiveRecord::Migration
  def change
    create_table :ticker_changes do |t|
      t.string :ticker_symbol
      t.date :action_date
      t.string :type
      t.string :old_value
      t.string :new_value

      t.timestamps null: false
    end
  end
end
