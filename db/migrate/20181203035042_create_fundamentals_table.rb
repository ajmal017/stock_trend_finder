class CreateFundamentalsTable < ActiveRecord::Migration
  def up
    create_table(:fundamentals_histories) do |t|
      t.string :ticker_symbol
      t.string :cusip
      t.date :scrape_date
      t.date :most_recent_dividend_date
      t.decimal :most_recent_dividend_amount
      t.decimal :dividend_yield_pct
      t.decimal :calculated_annual_dividend_amount
      t.decimal :market_cap
      t.decimal :shares_outstanding
      t.decimal :float
    end

    add_column :tickers, :annual_dividend_amount, :decimal
    remove_column :tickers, :adr
    remove_column :tickers, :note
    remove_column :tickers, :gap_up_note
  end

  def down
    drop_table(:fundamentals_histories)

    remove_column :tickers, :annual_dividend_amount
    add_column :tickers, :adr, :string
    add_column :tickers, :note, :string
    add_column :tickers, :gap_up_note, :string
  end
end
