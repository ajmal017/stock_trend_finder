require 'rails_helper'

describe MarketDataUtilities::InstitutionalOwnership::ParsePageData do
  subject { convert_float_numbers(described_class.call(page_html: page).value) }

  let(:page) do
    File.open(Rails.root.join('spec/support/nasdaq_institutional_ownership_page_sample.html')) { |f| f.read }
  end

  let(:expected_result) do
    convert_float_numbers(
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
    )
  end

  def convert_float_numbers(hash)
    Utilities::ConvertHashFloatsToStrings.convert_hash_floats_to_strings(hash)
  end

  it { is_expected.to eql(expected_result) }

end