require 'rails_helper'

describe MarketDataUtilities::InstitutionalOwnership::ScrapeNasdaqPage do
  subject { described_class.call(symbol: 'AAPL').value }

  it 'returns figures' do
    expect(subject).to be_a(Hash)

    subject.keys.each do |key|
      expect(subject[key]).to be_kind_of(Numeric), "#{key} returned is not a number"
      expect(subject[key]).to be > 0, "#{key} returned seems to be invalid"
    end
  end
end