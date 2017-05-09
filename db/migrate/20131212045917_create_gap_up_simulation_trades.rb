class CreateGapUpSimulationTrades < ActiveRecord::Migration
  def change
    create_table :gap_up_simulation_trades do |t|
      t.integer :gap_up_id
      t.integer :simulation_id
      t.integer :ticker_id
      t.string :ticker_symbol
      t.date :open_date
      t.date :close_date
      t.decimal :value_begin
      t.decimal :value_end

      t.timestamps
    end
  end
end
