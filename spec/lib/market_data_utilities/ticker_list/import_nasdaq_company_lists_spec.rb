require 'rails_helper'

describe MarketDataUtilities::TickerList::ImportNasdaqCompanyLists do
  subject { described_class.call(date: Date.new(2017,4,29)) }

  let(:existing_database_records) do
    [
      { symbol: 'MBLY', company_name: 'Mobileye', sector: 'Electronics', industry: 'Gadgets', market_cap: 1000000000.0, scrape_data: true, on_nasdaq_list: true },
      { symbol: 'PIH', company_name: '1347 Property Insurance Holdings, Inc.', market_cap: 111.0, sector:'Finance	Property-Casualty', industry: 'Insurers', scrape_data: false, on_nasdaq_list: true },
      { symbol: 'TURN', company_name: 'Turn Corporation', market_cap: 222.0, sector: 'Different Sector', industry: 'Different Industry', scrape_data: true, on_nasdaq_list: true },
    ]
  end

  let(:expected_database_records) do
    [
      { symbol: 'MBLY', company_name: 'Mobileye', sector: 'Electronics', industry: 'Gadgets', market_cap: 1000000000.0, scrape_data: true, on_nasdaq_list: false },
      { symbol: 'PIH', company_name: '1347 Property Insurance Holdings, Inc.', market_cap: BigDecimal.new('43480000'), sector: 'Finance', industry: 'Property-Casualty Insurers', scrape_data: false, on_nasdaq_list: true },
      { symbol: 'TURN', company_name: '180 Degree Capital Corp.', market_cap: BigDecimal.new('44500000'), sector: 'Finance', industry: 'Finance/Investors Services', scrape_data: true, on_nasdaq_list: true },
      { symbol: 'FLWS', company_name:	'1-800 FLOWERS.COM, Inc.', market_cap: BigDecimal.new('704870000'), sector: 'Consumer Services', industry: 'Other Specialty Stores', scrape_data: true, on_nasdaq_list: true },
    ]
  end

  before do
    stub_const('STOCK_TREND_FINDER_DATA_DIR', File.join(Dir.pwd, 'spec/support/stock_trend_finder_data_dir/'))

    existing_database_records.each { |attrs| Ticker.create!(attrs) }
  end

  it 'updates the database' do
    subject

    expected_database_records.each do |attrs|
      expect(Ticker.find_by(attrs)).to be_present,
        "Expected:\n#{attrs}\n\nDB has:\n#{Ticker.find_by(symbol:attrs[:symbol]).try(:attributes).try(:symbolize_keys).try(:slice, *attrs.keys)}"
    end
  end
end