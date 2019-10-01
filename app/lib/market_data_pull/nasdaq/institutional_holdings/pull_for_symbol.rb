module MarketDataPull; module Nasdaq; module InstitutionalHoldings
  class PullForSymbol
    include Verbalize::Action

    input :symbol

    def call
      {
        institutional_ownership_pct:  format(section('ownershipSummary')['SharesOutstandingPCT'].try(:[], 'value')),
        total_shares:                 format(section('ownershipSummary')['ShareoutstandingTotal'].try(:[], 'value')),
        holdings_value:               format(section('ownershipSummary')['TotalHoldingsValue'].try(:[], 'value')),
        increased_positions_count:    format(section_row('activePositions', 'Increased Positions').try(:[], 'holders')),
        decreased_positions_count:    format(section_row('activePositions', 'Decreased Positions').try(:[], 'holders')),
        held_positions_count:         format(section_row('activePositions', 'Held Positions').try(:[], 'holders')),
        increased_positions_shares:   format(section_row('activePositions', 'Increased Positions').try(:[], 'shares')),
        decreased_positions_shares:   format(section_row('activePositions', 'Decreased Positions').try(:[], 'shares')),
        held_positions_shares:        format(section_row('activePositions', 'Held Positions').try(:[], 'shares')),
        new_positions_count:          format(section_row('newSoldOutPositions', 'New Positions').try(:[], 'holders')),
        sold_positions_count:         format(section_row('newSoldOutPositions', 'Sold Out Positions').try(:[], 'holders')),
        new_positions_shares:         format(section_row('newSoldOutPositions', 'New Positions').try(:[], 'shares')),
        sold_positions_shares:        format(section_row('newSoldOutPositions', 'Sold Out Positions').try(:[], 'shares')),
        latest_filing_date:           latest_filing_date
      }
    end

    private

    def section_row(section_name, row_name)
      ap = section(section_name)
      return if ap.blank? || ap['rows'].blank?

      ap['rows'].find { |row| row['positions']==row_name }
    end

    def format(value)
      return nil if value.blank?
      value
        .gsub('$', '')
        .gsub(',', '')
        .gsub('%', '')
        .strip
        .to_f
    end

    def json
      HTTParty.get(query_url)
    rescue StandardError
      {}
    end

    def latest_filing_date
      json['data']['holdingsTransactions']['table']['rows'].map { |row| Date.strptime(row['date'], '%m/%d/%Y') }.max
    end

    def section(header)
      json['data'].try(:[], header) || {}
    end

    def query_url
      "https://api.nasdaq.com/api/company/#{symbol}/institutional-holdings?limit=99999&type=TOTAL"
    end

  end
end; end; end