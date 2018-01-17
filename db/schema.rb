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

ActiveRecord::Schema.define(version: 20170708135201) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "after_hours_prices", force: :cascade do |t|
    t.date     "price_date"
    t.string   "ticker_symbol",        limit: 255
    t.float    "high"
    t.float    "low"
    t.float    "volume"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "last_trade"
    t.datetime "latest_print_time"
    t.float    "intraday_high"
    t.float    "intraday_low"
    t.float    "intraday_close"
    t.float    "average_volume_50day"
  end

  add_index "after_hours_prices", ["ticker_symbol", "price_date"], name: "index_after_hours_prices_on_ticker_symbol_and_price_date", unique: true, using: :btree

  create_table "daily_stock_prices", force: :cascade do |t|
    t.integer  "ticker_id"
    t.date     "price_date"
    t.float    "open"
    t.float    "high"
    t.float    "low"
    t.float    "close"
    t.float    "volume"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ticker_symbol",        limit: 255
    t.float    "previous_close"
    t.float    "previous_high"
    t.float    "previous_low"
    t.boolean  "exclude",                          default: false
    t.float    "average_volume_50day"
    t.decimal  "ema13"
    t.string   "candle_vs_ema13",      limit: 255
    t.datetime "snapshot_time"
    t.float    "sma50"
    t.float    "sma200"
    t.float    "high_52_week"
    t.float    "low_52_week"
  end

  add_index "daily_stock_prices", ["price_date"], name: "index_daily_stock_prices_on_price_date", using: :btree
  add_index "daily_stock_prices", ["ticker_symbol", "price_date"], name: "index_daily_stock_prices_on_ticker_symbol_and_price_date", unique: true, using: :btree

  create_table "dividends", force: :cascade do |t|
    t.integer  "ticker_id"
    t.date     "issue_date"
    t.decimal  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dividends", ["ticker_id", "issue_date"], name: "index_dividends_on_ticker_id_and_issue_date", unique: true, using: :btree

  create_table "earnings_days", force: :cascade do |t|
    t.date     "earnings_date"
    t.boolean  "before_the_open"
    t.string   "tickers"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "earnings_days", ["earnings_date", "before_the_open"], name: "index_earnings_days_date", unique: true, using: :btree

  create_table "institutional_ownership_snapshots", force: :cascade do |t|
    t.string   "ticker_symbol"
    t.date     "scrape_date"
    t.float    "institutional_ownership_pct"
    t.integer  "total_shares",                limit: 8
    t.integer  "holdings_value",              limit: 8
    t.integer  "increased_positions_count"
    t.integer  "decreased_positions_count"
    t.integer  "held_positions_count"
    t.integer  "increased_positions_shares",  limit: 8
    t.integer  "decreased_positions_shares",  limit: 8
    t.integer  "held_positions_shares",       limit: 8
    t.integer  "new_positions_count"
    t.integer  "sold_positions_count"
    t.integer  "new_positions_shares",        limit: 8
    t.integer  "sold_positions_shares",       limit: 8
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "low_liquidity_quarters", force: :cascade do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol",      limit: 255
    t.string   "quarter",            limit: 255
    t.integer  "year"
    t.integer  "low_liquidity_days"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memoized_fields", force: :cascade do |t|
    t.string   "ticker_symbol"
    t.date     "price_date"
    t.float    "premarket_average_volume_50day"
    t.float    "premarket_previous_high"
    t.float    "premarket_previous_low"
    t.float    "premarket_previous_close"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "minute_stock_prices", force: :cascade do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol", limit: 255
    t.datetime "price_time"
    t.decimal  "open"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "close"
    t.decimal  "volume",                    precision: 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "minute_stock_prices", ["price_time"], name: "index_minute_stock_prices_on_price_time", using: :btree
  add_index "minute_stock_prices", ["ticker_id", "price_time"], name: "index_minute_stock_prices_on_ticker_id_and_price_time", unique: true, using: :btree
  add_index "minute_stock_prices", ["ticker_symbol"], name: "index_minute_stock_prices_on_ticker_symbol", using: :btree

  create_table "open_positions", force: :cascade do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol",      limit: 255
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

  create_table "premarket_prices", force: :cascade do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol",        limit: 255
    t.date     "price_date"
    t.datetime "latest_print_time"
    t.float    "last_trade"
    t.float    "high"
    t.float    "low"
    t.float    "previous_high"
    t.float    "previous_low"
    t.float    "previous_close"
    t.float    "volume"
    t.float    "average_volume_50day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "premarket_prices", ["ticker_symbol", "price_date"], name: "index_premarket_prices_on_ticker_symbol_price_date", unique: true, using: :btree

  create_table "price_dates", force: :cascade do |t|
    t.date     "price_date"
    t.integer  "week"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "quarter",    limit: 255
    t.integer  "year"
  end

  create_table "real_time_quotes", force: :cascade do |t|
    t.string   "ticker_symbol", limit: 255
    t.float    "last_trade"
    t.datetime "quote_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "open"
    t.float    "low"
    t.float    "high"
    t.float    "volume"
  end

  add_index "real_time_quotes", ["ticker_symbol"], name: "index_real_time_quotes_ticker_symbol", using: :btree

  create_table "short_interest_histories", force: :cascade do |t|
    t.string   "ticker_symbol"
    t.date     "short_interest_date"
    t.float    "shares_short"
    t.float    "short_pct_float"
    t.float    "short_ratio"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.float    "float"
    t.string   "source"
    t.float    "average_volume"
  end

  add_index "short_interest_histories", ["ticker_symbol", "short_interest_date"], name: "index_on_short_interest_histories_ticker_sid", unique: true, using: :btree

  create_table "stock_prices15_minutes", force: :cascade do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol",         limit: 255
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

  create_table "stock_prices5_minutes", force: :cascade do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol",         limit: 255
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

  create_table "stock_splits", force: :cascade do |t|
    t.integer  "ticker_id"
    t.date     "split_date"
    t.decimal  "receive_shares"
    t.decimal  "for_every_shares"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "adjustment_made"
  end

  create_table "stock_trades", force: :cascade do |t|
    t.integer  "price_gap_id"
    t.string   "action",        limit: 255
    t.decimal  "pct_value_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stocktwit_hashtags", force: :cascade do |t|
    t.integer  "stocktwit_id"
    t.string   "tag",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stocktwit_hashtags", ["stocktwit_id", "tag"], name: "index_stocktwit_hashtags_on_stocktwit_id_and_tag", unique: true, using: :btree

  create_table "stocktwit_tickers", force: :cascade do |t|
    t.integer  "stocktwit_id"
    t.string   "ticker_symbol", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stocktwit_tickers", ["ticker_symbol"], name: "index_ticker_symbols_on_stocktwit_tickers", using: :btree

  create_table "stocktwit_watch_tickers", force: :cascade do |t|
    t.string   "ticker_symbol", limit: 255
    t.boolean  "watching"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stocktwit_watch_tickers", ["ticker_symbol"], name: "index_stocktwit_watch_tickers_on_ticker_symbol", unique: true, using: :btree

  create_table "stocktwits", force: :cascade do |t|
    t.integer  "stocktwit_id"
    t.datetime "stocktwit_time"
    t.string   "stocktwit_url",        limit: 255
    t.string   "symbol",               limit: 255
    t.string   "message",              limit: 255
    t.string   "image_thumb_url",      limit: 255
    t.string   "image_large_url",      limit: 255
    t.string   "image_original_url",   limit: 255
    t.boolean  "hide"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stocktwits_user_name", limit: 255
    t.integer  "call_result"
    t.string   "note"
    t.date     "stocktwit_date"
  end

  add_index "stocktwits", ["stocktwit_date"], name: "index_stocktwits_on_stocktwit_date", using: :btree

  create_table "ticker_notes", force: :cascade do |t|
    t.integer  "ticker_id"
    t.string   "ticker_symbol"
    t.date     "note_date"
    t.string   "note_type"
    t.text     "note_text"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "ticker_notes", ["ticker_symbol"], name: "index_ticker_notes_on_ticker_symbol", using: :btree

  create_table "tickers", force: :cascade do |t|
    t.string   "symbol",                         limit: 255
    t.string   "company_name",                   limit: 255
    t.string   "exchange",                       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "scrape_data"
    t.string   "sector",                         limit: 255
    t.string   "industry",                       limit: 255
    t.decimal  "market_cap"
    t.boolean  "track_gap_up"
    t.string   "gap_up_note",                    limit: 255
    t.boolean  "adr"
    t.string   "note",                           limit: 255
    t.float    "float"
    t.float    "institutional_holdings_percent"
    t.date     "hide_from_reports_until"
    t.date     "short_interest_date"
    t.float    "short_ratio"
    t.float    "short_pct_float"
    t.boolean  "on_nasdaq_list"
    t.date     "unscrape_date"
    t.date     "date_added"
    t.boolean  "sp500"
  end

  add_index "tickers", ["symbol"], name: "index_tickers_on_symbol", unique: true, using: :btree

  create_table "vix_daily_histories", force: :cascade do |t|
    t.date     "price_date"
    t.float    "open"
    t.float    "high"
    t.float    "low"
    t.float    "close"
    t.float    "long_term_average"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "vix_futures_histories", force: :cascade do |t|
    t.datetime "snapshot_time"
    t.decimal  "contango_percent",    precision: 5,  scale: 2
    t.text     "futures_curve"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.decimal  "VIX",                 precision: 6,  scale: 2
    t.string   "screenshot_filename"
    t.decimal  "XIV",                 precision: 15, scale: 2
    t.text     "report_fields"
  end

end
