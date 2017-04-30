require 'rails_helper'

describe MarketDataUtilities::TickerList::LineItemFilter do

  context '.convert_market_caps' do
    subject { described_class.convert_market_caps(new_tickers) }

    let(:new_tickers) do
      [
        { symbol: 'XXII', company_name: '22nd Century Group, Inc', market_cap: '$126.98M' },
        { symbol: 'MIW', company_name: 'Eaton Vance Michigan Municipal Bond Fund', market_cap: '$1.27B' },
        { symbol: 'ZBK', company_name: 'Zions Bancorporation', market_cap: 'n/a' },
      ]
    end

    let(:expected_returned_line_items) do
      [
        { symbol: 'XXII', company_name: '22nd Century Group, Inc', market_cap: 126980000.0 },
        { symbol: 'MIW', company_name: 'Eaton Vance Michigan Municipal Bond Fund', market_cap: 1270000000.0 },
        { symbol: 'ZBK', company_name: 'Zions Bancorporation' }, # drop the market cap cuz we don't want to update it
      ]
    end

    it { is_expected.to eql(expected_returned_line_items) }
  end

  context '.remove_invalid_tickers' do
    subject { described_class.remove_invalid_tickers(new_tickers) }

    let(:new_tickers) do
      [
        { symbol: 'XXII', company_name: '22nd Century Group, Inc' },
        { symbol: 'ADK^A', company_name: 'Adcare Health Systems Inc' },
        { symbol: 'CMG-B', company_name: 'Chipotle Mexican Grill Class B Shares'},
        { symbol: 'ASB.WS', company_name: 'BioTime, Inc.' },
      ]
    end

    let(:expected_returned_line_items) do
      [
        { symbol: 'XXII', company_name: '22nd Century Group, Inc' },
      ]
    end

    it { is_expected.to eql(expected_returned_line_items) }
  end

  context '.remove_missing_industry_tag' do
    subject { described_class.remove_missing_industry_tag(new_tickers) }

    let(:new_tickers) do
      [
        { symbol: 'XXII', company_name: '22nd Century Group, Inc', sector: 'Consumer Non-Durables', industry: 'Farming/Seeds/Milling' },
        { symbol: 'MIW', company_name: 'Eaton Vance Michigan Municipal Bond Fund', sector: 'n/a', industry: 'n/a' },
      ]
    end

    let(:expected_returned_line_items) do
      [
        { symbol: 'XXII', company_name: '22nd Century Group, Inc', sector: 'Consumer Non-Durables', industry: 'Farming/Seeds/Milling' },
      ]
    end

    it { is_expected.to eql(expected_returned_line_items) }
  end

end