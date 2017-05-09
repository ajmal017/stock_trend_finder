class CreateOpenPositions < ActiveRecord::Migration
  def change
    create_table :open_positions do |t|
      t.integer :ticker_id
      t.string :ticker_symbol
      t.date :open_date
      t.decimal :gap_up_price
      t.decimal :buy_price
      t.decimal :stop_loss_initial
      t.decimal :stop_loss_4pct
      t.decimal :stop_loss_8pct
      t.boolean :hit_stop_loss_4pct
      t.boolean :hit_stop_loss_8pct
      t.decimal :sell_price

      t.timestamps
    end
  end
end
