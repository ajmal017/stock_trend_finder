require 'rails_helper'

describe MarketDataUtilities::TickerList::InsertLineItems do
  subject { described_class.(input: inputs) }

  context 'when records for the given ticker symbols do not exist' do
    let(:inputs) do
      [
        { symbol: 'XXII', company_name: '22nd Century Group, Inc', sector: 'Consumer Non-Durables', industry: 'Farming/Seeds/Milling', market_cap: 1234.0 },
        { symbol: 'MIW', company_name: 'Eaton Vance Michigan Municipal Bond Fund', sector: 'n/a', industry: 'n/a', market_cap: 9876.0  },
      ]
    end

    let(:expected_new_records) do
      [
        { symbol: 'XXII', company_name: '22nd Century Group, Inc', sector: 'Consumer Non-Durables', industry: 'Farming/Seeds/Milling', market_cap: 1234.0, scrape_data: true, on_nasdaq_list: true },
        { symbol: 'MIW', company_name: 'Eaton Vance Michigan Municipal Bond Fund', sector: 'n/a', industry: 'n/a', market_cap: 9876.0, scrape_data: true, on_nasdaq_list: true  },
      ]
    end

    it 'adds new records' do
      expect { subject }.to change { Ticker.count }.by(expected_new_records.size)
      expected_new_records.each do |attrs|
        expect(Ticker.find_by(attrs)).to be_present
      end
    end
  end

  context 'when records for the given ticker symbols exist' do
    let(:existing_records) do
      [
      {symbol: "AAON", company_name: "AAON, Inc.", exchange: "nasdaq", sector: "Capital Goods", industry: "Industrial Machinery/Components", scrape_data: true, market_cap: 945659614.86, on_nasdaq_list: true},
      {symbol: "SLB", company_name: "Schlumberger N.V.", exchange: "nyse", sector: "Energy", industry: "Oilfield Services/Equipment", scrape_data: true, market_cap: BigDecimal.new('117884953486.44'), on_nasdaq_list: true},
      {symbol: "AFCE", company_name: "AFC Enterprises, Inc.", exchange: "nasdaq", sector: "Consumer Services", industry: "Restaurants", scrape_data: false, market_cap: 1031814543.0, on_nasdaq_list: false},
      {symbol: "NCLH", company_name: "Norwegian Cruise Line Holdings Ltd.", exchange: "nasdaq", sector: "Consumer Services", industry: "Marine Transportation", scrape_data: true, market_cap: nil, on_nasdaq_list: true},
      {symbol: "OLDT", company_name: "An Old Defunct Ticker Symbol", exchange: "nasdaq", sector: "Entertainment", industry: "Games", scrape_data: false, market_cap: nil, on_nasdaq_list: false},
      ]
    end

    let(:inputs) do
      [
      {symbol: "AAON", company_name: "AAON, Inc.", exchange: "nasdaq", sector: "Capital Goods", industry: "Industrial Machinery/Components", market_cap: 900000000.0},
      {symbol: "SLB", company_name: "Schlumberger Corporation", exchange: "nyse", sector: "Energy", industry: "Oil Services", market_cap: nil},
      {symbol: "OLDT", company_name: "Ticker Reused Under a New Name", exchange: "nasdaq", sector: "Energy", industry: "Oil Services", market_cap: nil},
      ]
    end

    let(:expected_updated_records) do
      [
      {symbol: "AAON", company_name: "AAON, Inc.", exchange: "nasdaq", sector: "Capital Goods", industry: "Industrial Machinery/Components", scrape_data: true, market_cap: 900000000.0, on_nasdaq_list: true},
      {symbol: "SLB", company_name: "Schlumberger Corporation", exchange: "nyse", sector: "Energy", industry: "Oil Services", scrape_data: true, market_cap: BigDecimal.new('117884953486.44'), on_nasdaq_list: true},
      {symbol: "AFCE", company_name: "AFC Enterprises, Inc.", exchange: "nasdaq", sector: "Consumer Services", industry: "Restaurants", scrape_data: false, market_cap: 1031814543.0, on_nasdaq_list: false},
      {symbol: "NCLH", company_name: "Norwegian Cruise Line Holdings Ltd.", exchange: "nasdaq", sector: "Consumer Services", industry: "Marine Transportation", scrape_data: false, market_cap: nil, on_nasdaq_list: false},
      {symbol: "OLDT", company_name: "Ticker Reused Under a New Name", exchange: "nasdaq", sector: "Energy", industry: "Oil Services", scrape_data: true, market_cap: nil, on_nasdaq_list: true},
      ]
    end

    let(:return_value) do
      {
        updated_company_names: [
          { symbol: 'SLB', previous_company_name: 'Schlumberger N.V.', new_company_name: 'Schlumberger Corporation' },
        ]
      }
    end

    before do
      existing_records.each { |attrs| Ticker.create(attrs) }
    end

    it 'updates the existing market data' do
      expect { subject }.to change { Ticker.count }.by(0) # just updating records in this case, not adding
      expected_updated_records.each do |attrs|
        expect(Ticker.find_by(attrs)).to be_present,
          "Expected:\n#{attrs}\n\nDB has:\n#{Ticker.find_by(symbol:attrs[:symbol]).attributes.symbolize_keys.slice(*attrs.keys)}"
      end
    end
  end

end