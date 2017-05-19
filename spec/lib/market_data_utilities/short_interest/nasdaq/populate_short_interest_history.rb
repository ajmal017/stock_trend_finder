require 'rails_helper'

describe MarketDataUtilities::ShortInterest::Nasdaq::PopulateShortInterestHistory do
  subject { described_class.(symbol: symbol, values: values) }

  let(:symbol) { 'KNDI' }

  let(:values) do
    [
      {:settlement_date=>Date.new(2017,4,28), :short_interest=>5346.623, :average_volume=>970.59, :days_to_cover=>5.508632},
      {:settlement_date=>Date.new(2017,4,13), :short_interest=>5410.23, :average_volume=>538.68, :days_to_cover=>10.043495},
      {:settlement_date=>Date.new(2017,3,31), :short_interest=>5088.752, :average_volume=>834.465, :days_to_cover=>6.098221},
      {:settlement_date=>Date.new(2017,3,15), :short_interest=>6096.453, :average_volume=>1245.109, :days_to_cover=>4.896321},
      {:settlement_date=>Date.new(2017,2,28), :short_interest=>5743.427, :average_volume=>2094.171, :days_to_cover=>2.742578},
      {:settlement_date=>Date.new(2017,2,15), :short_interest=>4488.555, :average_volume=>515.314, :days_to_cover=>8.71033},
      {:settlement_date=>Date.new(2017,1,31), :short_interest=>4452.978, :average_volume=>507.455, :days_to_cover=>8.775119},
      {:settlement_date=>Date.new(2017,1,13), :short_interest=>4556.07, :average_volume=>894.947, :days_to_cover=>5.090882},
      {:settlement_date=>Date.new(2016,12,30), :short_interest=>4043.622, :average_volume=>558.64, :days_to_cover=>7.238332},
      {:settlement_date=>Date.new(2016,12,15), :short_interest=>4172.103, :average_volume=>708.561, :days_to_cover=>5.888135},
      {:settlement_date=>Date.new(2016,11,30), :short_interest=>4705.927, :average_volume=>773.24, :days_to_cover=>6.085985},
      {:settlement_date=>Date.new(2016,11,15), :short_interest=>5223.89, :average_volume=>1230.957, :days_to_cover=>4.243763},
      {:settlement_date=>Date.new(2016,10,31), :short_interest=>5474.747, :average_volume=>780.424, :days_to_cover=>7.015093},
      {:settlement_date=>Date.new(2016,10,14), :short_interest=>5373.532, :average_volume=>952.412, :days_to_cover=>5.642025},
      {:settlement_date=>Date.new(2016,9,30), :short_interest=>5645.926, :average_volume=>1229.884, :days_to_cover=>4.590617},
      {:settlement_date=>Date.new(2016,9,15), :short_interest=>5345.92, :average_volume=>610.653, :days_to_cover=>8.754432},
      {:settlement_date=>Date.new(2016,8,31), :short_interest=>5684.527, :average_volume=>595.127, :days_to_cover=>9.551788},
      {:settlement_date=>Date.new(2016,8,15), :short_interest=>5998.7, :average_volume=>1778.686, :days_to_cover=>3.372546},
      {:settlement_date=>Date.new(2016,7,29), :short_interest=>6015.046, :average_volume=>993.071, :days_to_cover=>6.057015},
      {:settlement_date=>Date.new(2016,7,15), :short_interest=>5713.504, :average_volume=>545.04, :days_to_cover=>10.482724},
      {:settlement_date=>Date.new(2016,6,30), :short_interest=>6317.447, :average_volume=>739.913, :days_to_cover=>8.538094},
      {:settlement_date=>Date.new(2016,6,15), :short_interest=>6754.362, :average_volume=>517.152, :days_to_cover=>13.06069},
      {:settlement_date=>Date.new(2016,5,31), :short_interest=>6464.045, :average_volume=>627.696, :days_to_cover=>10.29805},
      {:settlement_date=>Date.new(2016,5,13), :short_interest=>5985.35, :average_volume=>1981.867, :days_to_cover=>3.020056}
    ]
  end

  let(:example_symbol) do
    'KNDI'
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
    Ticker.create(symbol: example_symbol, float: 11800)
  end

  it 'puts the values in the database' do
    expect { subject }.to change { ShortInterestHistory.count }.by(values.size)

    r = ShortInterestHistory.find_by(ticker_symbol: example_symbol, short_interest_date: Date.new(2016,5,31))
    expect(r.shares_short.round(3).to_s).to eql('6464.045')
    expect(r.average_volume.round(3).to_s).to eql('627.696')
    expect(r.short_ratio.round(3).to_s).to eql('10.298')

    r = ShortInterestHistory.find_by(ticker_symbol: example_symbol, short_interest_date: Date.new(2017,4,28))
    expect(r.shares_short.round(3).to_s).to eql('5346.623')
    expect(r.average_volume.round(3).to_s).to eql('970.59')
    expect(r.short_ratio.round(3).to_s).to eql('5.509')

    t = Ticker.find_by(symbol: example_symbol)
    expect(t.short_interest_date).to eql(Date.new(2017,4,28))
    expect(t.short_pct_float.round(3).to_s).to eql('0.453')
    expect(t.short_ratio.round(3).to_s).to eql('5.509')
  end

end