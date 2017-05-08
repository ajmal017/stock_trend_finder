require 'rails_helper'

describe MarketDataUtilities::InstitutionalOwnership::PopulateNewSnapshot do
  subject { described_class.(symbol: symbol, values: values) }

  let(:symbol) { 'AAPL' }

  let(:values) do
    {
      institutional_ownership_pct: 41.04,
      total_shares: 7000000,
      holdings_value: 31000000,
      increased_positions_count: 17,
      decreased_positions_count: 11,
      held_positions_count: 15,
      increased_positions_shares: 317820,
      decreased_positions_shares: 79986,
      held_positions_shares: 2583324,
      new_positions_count: 5,
      sold_positions_count: 1,
      new_positions_shares: 57491,
      sold_positions_shares: 19971,
    }
  end

  let(:expected_new_record_attributes) do
    convert_float_numbers(values).merge({
      ticker_symbol: symbol,
      scrape_date: Date.today,
    })
  end

  let(:new_record_attributes) do
    convert_float_numbers(
      InstitutionalOwnershipSnapshot.last.attributes.symbolize_keys.slice(*expected_new_record_attributes.keys)
    )
  end

  def convert_float_numbers(hash)
    Utilities::ConvertHashFloatsToStrings.convert_hash_floats_to_strings(hash)
  end

  before do
    Ticker.create(symbol: 'AAPL')
  end

  it 'puts the values in the database' do
    expect { subject }.to change { InstitutionalOwnershipSnapshot.count }.by(1)
    expect(new_record_attributes).to eql(expected_new_record_attributes)

    expect(Ticker.find_by(symbol: 'AAPL').institutional_holdings_percent.to_s).to eql(values[:institutional_ownership_pct].to_s)
  end

end