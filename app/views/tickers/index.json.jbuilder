json.array!(@tickers) do |ticker|
  json.extract! ticker, :id, :symbol, :company_name, :scrape_data, :track_gap_up, :date_removed
  json.url ticker_url(ticker, format: :json)
end
