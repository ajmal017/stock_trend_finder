# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150201003934) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "after_hours_prices", force: true do |t|
    t.date     "price_date"
    t.string   "ticker_symbol"
    t.decimal  "ah_high"
    t.decimal  "ah_low"
    t.decimal  "ah_volume"
    t.decimal  "ah_vwap"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "daily_stock_prices", force: true do |t|
    t.integer  "ticker_id"
    t.date     "price_date"
    t.decimal  "open"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "close"
    t.decimal  "volume",               precision: 15, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ticker_symbol"
    t.decimal  "previous_close"
    t.decimal  "previous_high"
    t.decimal  "previous_low"
    t.boolean  "exclude",                                       default: false
    t.decimal  "average_volume_50day"
    t.decimal  "ema13"
    t.string   "candle_vs_ema13"
    t.datetime "snapshot_time"
    t.decimal  "sma50"
    t.decimal  "sma200"
  end

  add_index "daily_stock_prices", ["price_date"], name: "index_daily_stock_prices_on_price_date", using: :btree
  add_index "daily_stock_prices", ["ticker_id", "price_date"], name: "index_daily_stock_prices_on_ticker_id_and_price_date", unique: true, using: :btree
  add_index "daily_stock_prices", ["ticker_symbol"], name: "index_daily_stock_prices_on_ticker_symbol", using: :btree

  create_table "dividends", force: true do |t|
    t.integer  "ticker_id"
    t.date     "issue_date"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dividends", ["ticker_id", "issue_date"], name: "index_dividends_on_ticker_id_and_issue_date", unique: true, using: :btree

  create_table "gap_up_simulation_trades", force: true do |t|
    t.integer  "gap_up_id"
    t.integer  "simulation_id"
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.date     "open_date"
    t.date     "close_date"
    t.decimal  "value_begin"
    t.decimal  "value_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "portfolio_value"
    t.decimal  "cash"
    t.decimal  "invested_value"
    t.decimal  "trade_open"
    t.decimal  "trade_close"
  end

  create_table "gap_ups", force: true do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.date     "price_date"
    t.decimal  "open"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "close"
    t.decimal  "previous_close"
    t.decimal  "previous_high"
    t.decimal  "previous_low"
    t.decimal  "open_pct_of_previous_high"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "strategy_number"
    t.decimal  "trade_outcome"
    t.integer  "week"
    t.decimal  "last_year_close"
    t.decimal  "pct_of_last_year_close"
  end

  create_table "low_liquidity_quarters", force: true do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.string   "quarter"
    t.integer  "year"
    t.integer  "low_liquidity_days"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "minute_stock_prices", force: true do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.datetime "price_time"
    t.decimal  "open"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "close"
    t.decimal  "volume",        precision: 15, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "minute_stock_prices", ["price_time"], name: "index_minute_stock_prices_on_price_time", using: :btree
  add_index "minute_stock_prices", ["ticker_id", "price_time"], name: "index_minute_stock_prices_on_ticker_id_and_price_time", unique: true, using: :btree
  add_index "minute_stock_prices", ["ticker_symbol"], name: "index_minute_stock_prices_on_ticker_symbol", using: :btree

  create_table "open_positions", force: true do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.date     "open_date"
    t.decimal  "gap_up_price"
    t.decimal  "buy_price"
    t.decimal  "stop_loss_initial"
    t.decimal  "stop_loss_4pct"
    t.decimal  "stop_loss_8pct"
    t.boolean  "hit_stop_loss_4pct"
    t.boolean  "hit_stop_loss_8pct"
    t.decimal  "sell_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
  end

  create_table "price_dates", force: true do |t|
    t.date     "price_date"
    t.integer  "week"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "quarter"
    t.integer  "year"
  end

  create_table "real_time_quotes", force: true do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.decimal  "last_trade"
    t.datetime "quote_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "run_time"
    t.decimal  "open"
    t.decimal  "low"
    t.decimal  "high"
    t.decimal  "volume",        precision: 15, scale: 0
  end

  create_table "stock_prices15_minutes", force: true do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.datetime "price_time"
    t.decimal  "open"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "close"
    t.decimal  "volume"
    t.decimal  "true_range"
    t.decimal  "true_range_percent"
    t.decimal  "average_true_range_60"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_prices15_minutes", ["price_time"], name: "index_stock_prices15_minutes_on_price_time", using: :btree
  add_index "stock_prices15_minutes", ["ticker_symbol"], name: "index_stock_prices15_minutes_on_ticker_symbol", using: :btree

  create_table "stock_prices5_minutes", force: true do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.datetime "price_time"
    t.decimal  "open"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "close"
    t.decimal  "volume"
    t.decimal  "true_range"
    t.decimal  "true_range_percent"
    t.decimal  "average_true_range_60"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stock_prices5_minutes", ["price_time"], name: "index_stock_prices5_minutes_on_price_time", using: :btree
  add_index "stock_prices5_minutes", ["ticker_symbol"], name: "index_stock_prices5_minutes_on_ticker_symbol", using: :btree

  create_table "stock_splits", force: true do |t|
    t.integer  "ticker_id"
    t.date     "split_date"
    t.decimal  "receive_shares"
    t.decimal  "for_every_shares"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "adjustment_made"
  end

  create_table "stock_trades", force: true do |t|
    t.integer  "price_gap_id"
    t.string   "action"
    t.decimal  "pct_value_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stocktwit_tickers", force: true do |t|
    t.integer  "stocktwit_id"
    t.string   "ticker_symbol"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stocktwit_tickers", ["ticker_symbol"], name: "index_ticker_symbols_on_stocktwit_tickers", using: :btree

  create_table "stocktwit_watch_tickers", force: true do |t|
    t.string   "ticker_symbol"
    t.boolean  "watching"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stocktwit_watch_tickers", ["ticker_symbol"], name: "index_stocktwit_watch_tickers_on_ticker_symbol", unique: true, using: :btree

  create_table "stocktwits", force: true do |t|
    t.integer  "stocktwit_id"
    t.datetime "stocktwit_time"
    t.string   "stocktwit_url"
    t.string   "symbol"
    t.string   "message"
    t.string   "image_thumb_url"
    t.string   "image_large_url"
    t.string   "image_original_url"
    t.boolean  "hide"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "watching"
    t.string   "stocktwits_user_name"
    t.integer  "call_result"
  end

  create_table "tickers", force: true do |t|
    t.string   "symbol"
    t.string   "company_name"
    t.string   "exchange"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "scrape_data"
    t.string   "sector"
    t.string   "industry"
    t.decimal  "market_cap"
    t.boolean  "djia"
    t.boolean  "sp500"
    t.boolean  "track_gap_up"
    t.boolean  "pullback_alerts"
    t.string   "gap_up_note"
    t.boolean  "adr"
    t.boolean  "russell3000"
    t.datetime "date_removed"
    t.string   "note"
    t.decimal  "float"
    t.decimal  "institutional_holdings_percent"
    t.date     "hide_from_reports_until"
  end

  add_index "tickers", ["symbol"], name: "index_tickers_on_symbol", using: :btree

  create_table "trade_positions", force: true do |t|
    t.integer  "gap_up_id"
    t.date     "trade_date"
    t.string   "position"
    t.decimal  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price"
    t.string   "reason"
    t.string   "ticker_symbol"
    t.date     "close_date"
    t.decimal  "close_value"
    t.integer  "ticker_id"
    t.decimal  "close_price"
  end

  add_index "trade_positions", ["gap_up_id", "position"], name: "index_trade_positions_on_gap_up_id_and_position", using: :btree

end
