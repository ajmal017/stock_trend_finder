require 'rails_helper'

describe MarketDataUtilities::Split::AdjustPrices do
  let(:symbol) { 'XYZ' }
  let(:beginning_dsp) do
    [
      { price_date: Date.new(2017,5,22), open: 10.10, high: 12.0, low: 9.0, close: 9.9, volume: 10_000.0 },
      { price_date: Date.new(2017,5,23), open: 10.20, high: 12.10, low: 9.1, close: 10.0, volume: 11_000.0 },
      { price_date: Date.new(2017,5,24), open: 10.30, high: 12.20, low: 9.2, close: 10.1, volume: 12_000.0 },
    ]
  end
  let(:beginning_pmp) do
    [
      { price_date: Date.new(2017,5,22), last_trade: 10.0, high: 10.05, low: 9.95, volume: 1_000.0 },
      { price_date: Date.new(2017,5,23), last_trade: 10.05, high: 10.10, low: 10.0, volume: 2_000.0 },
      { price_date: Date.new(2017,5,24), last_trade: 10.10, high: 10.20, low: 9.1, volume: 3_000.0 },
    ]
  end
  let(:beginning_ahp) do
    [
      { price_date: Date.new(2017,5,22), last_trade: 10.0, high: 10.05, low: 9.95, volume: 1_000.0 },
      { price_date: Date.new(2017,5,23), last_trade: 10.05, high: 10.10, low: 10.0, volume: 2_000.0 },
      { price_date: Date.new(2017,5,24), last_trade: 10.10, high: 10.20, low: 9.1, volume: 3_000.0 },
    ]
  end

  before do
    beginning_dsp.each { |dsp| DailyStockPrice.create({ticker_symbol: symbol}.merge(dsp)) }
    beginning_pmp.each { |pmp| PremarketPrice.create({ticker_symbol: symbol}.merge(pmp)) }
    beginning_ahp.each { |ahp| AfterHoursPrice.create({ticker_symbol: symbol}.merge(ahp)) }
  end

  def convert_float_numbers(array)
    array.each do |h|
      Utilities::ConvertHashFloatsToStrings.convert_hash_floats_to_strings(h)
    end
  end

  context '2:1 split' do
    subject { described_class.(symbol: symbol, as_of_date: as_of_date, given_shares: 2, for_every_shares: 1) }

    let(:as_of_date)  { Date.new(2017,5,24) }

    let(:expected_dsp) do
      beginning_dsp.each do |h|
        next if h[:price_date] >= as_of_date
        h.each do |k,v|
          if v.is_a?(Float)
            if k =~ /volume/
              h[k] = v * 2
            else
              h[k] = v / 2
            end
          end
        end
      end
    end

    let(:expected_pmp) do
      beginning_pmp.each do |h|
        next if h[:price_date] >= as_of_date
        h.each do |k,v|
          if v.is_a?(Float)
            if k =~ /volume/
              h[k] = v * 2
            else
              h[k] = v / 2
            end
          end
        end
      end
    end

    let(:expected_ahp) do
      beginning_ahp.each do |h|
        next if h[:price_date] >= as_of_date
        h.each do |k,v|
          if v.is_a?(Float)
            if k =~ /volume/
              h[k] = v * 2
            else
              h[k] = v / 2
            end
          end
        end
      end
    end

    let(:after_dsp) do
      keys = beginning_dsp.first.keys
      DailyStockPrice.all.map do |dsp|
        dsp.attributes.symbolize_keys.slice(*keys)
      end
    end

    let(:after_pmp) do
      keys = beginning_pmp.first.keys
      PremarketPrice.all.map do |p|
        p.attributes.symbolize_keys.slice(*keys)
      end
    end

    let(:after_ahp) do
      keys = beginning_ahp.first.keys
      AfterHoursPrice.all.map do |p|
        p.attributes.symbolize_keys.slice(*keys)
      end
    end

    it 'halves all the numbers' do
      subject
      expect(convert_float_numbers(after_dsp).to_set).to eql(convert_float_numbers(expected_dsp).to_set)
      expect(convert_float_numbers(after_pmp).to_set).to eql(convert_float_numbers(expected_pmp).to_set)
      expect(convert_float_numbers(after_ahp).to_set).to eql(convert_float_numbers(expected_ahp).to_set)

      last_dsp = DailyStockPrice.find_by(ticker_symbol: symbol, price_date: Date.new(2017,5,24))
      expect(last_dsp.average_volume_50day).to eql(21_000.0)
      expect(last_dsp.high_52_week).to eql(6.05)
    end

  end
end
