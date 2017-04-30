require 'rails_helper'

describe MarketDataUtilities::TickerList::UnscrapeShellCompanies do

  describe '.call' do
    subject { described_class.call }

    let(:existing_records) do
      [
        ['STLR',	'Stellar Acquisition III Inc.'],
        ['STLRU',	'Stellar Acquisition III Inc.'],
        ['STLRW',	'Stellar Acquisition III Inc.'],
        ['TACO',  'Del Taco Restaurants, Inc.'],
        ['TACOW', 'Del Taco Restaurants, Inc.']
      ]
    end

    let(:unscrapeable_records) do
      %w(STLRU STLRW TACOW)
    end

    let(:scrapeable_records) do
      %w(STLR TACO)
    end

    before do
      existing_records.each do |symbol, company_name|
        Ticker.create(symbol: symbol, company_name: company_name, scrape_data: true)
      end
    end

    it 'marks scrape_data to false' do
      subject

      unscrapeable_records.each { |symbol| expect(Ticker.find_by(symbol: symbol).scrape_data).to eql(false)}
      scrapeable_records.each { |symbol| expect(Ticker.find_by(symbol: symbol).scrape_data).to eql(true)}
    end
  end

end