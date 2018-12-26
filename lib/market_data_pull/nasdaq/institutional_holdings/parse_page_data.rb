module MarketDataPull
  module Nasdaq
    module InstitutionalHoldings
      class ParsePageData
        include Verbalize::Action

        ACCEPTED_TABLE_HEADERS = [
          'Institutional Ownership',
          'Total Shares Outstanding', # (millions)
          'Total Value of Holdings', # (millions)
          'Increased Positions',
          'Decreased Positions',
          'Held Positions',
          'Total Institutional Shares',
          'New Positions',
          'Sold Out Positions',
        ]

        input :page_html

        def call
          output_hash
        end

        private

        def column_contents_for_header(header, row)
          td_column_text_in_table_row(
            table_row_for_statistic(header),
            row
          )
        end

        def column_contents_for_header_as_number(header, row)
          value =
            column_contents_for_header(header, row).to_s
              .gsub('$', '')
              .gsub(',', '')
              .gsub('%', '')

          value.index('.') ? value.to_f : value.to_i
        end

        def td_column_text_in_table_row(tr, row)
          return nil if tr.nil?
          tr.css('td')[row].try(:text)
        end

        def noko
          @noko ||= Nokogiri.parse(page_html)
        end

        def output_hash
          {
            institutional_ownership_pct: column_contents_for_header_as_number('Institutional Ownership', 0),
            total_shares: column_contents_for_header_as_number('Total Shares Outstanding', 0) * 1000000,
            holdings_value: column_contents_for_header_as_number('Total Value of Holdings', 0) * 1000000,
            increased_positions_count: column_contents_for_header_as_number('Increased Positions', 0),
            decreased_positions_count: column_contents_for_header_as_number('Decreased Positions', 0),
            held_positions_count: column_contents_for_header_as_number('Held Positions', 0),
            increased_positions_shares: column_contents_for_header_as_number('Increased Positions', 1),
            decreased_positions_shares: column_contents_for_header_as_number('Decreased Positions', 1),
            held_positions_shares: column_contents_for_header_as_number('Held Positions', 1),
            new_positions_count: column_contents_for_header_as_number('New Positions', 0),
            sold_positions_count: column_contents_for_header_as_number('Sold Out Positions', 0),
            new_positions_shares: column_contents_for_header_as_number('New Positions', 1),
            sold_positions_shares: column_contents_for_header_as_number('Sold Out Positions', 1),
          }
        end

        def parse_institutional_ownership
          value = column_contents_for_header
          if value.is_a? String
            value.gsub('%', '').to_f
          else
            nil
          end
        end

        def table_row_for_statistic(statistic_name)
          table_headers.select { |th| th.text =~ /#{statistic_name}/ }.first.try(:parent)
        end

        def table_headers
          @table_headers = noko.css('th')
        end

      end
    end
  end
end