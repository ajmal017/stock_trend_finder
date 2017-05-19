module MarketDataUtilities
  module ShortInterest
    module Nasdaq
      class ParsePageData
        include Verbalize::Action

        input :page_html

        def call
          return [] if short_interest_table.nil?

          data_rows.map do |row|
            next if row.any?(&:empty?)
            begin
              settlement_date, short_interest, average_volume, days_to_cover = row
              {
                settlement_date: Date.strptime(settlement_date, '%m/%d/%Y'),
                short_interest: short_interest.gsub(',', '').to_f / 1000,
                average_volume: average_volume.gsub(',', '').to_f / 1000,
                days_to_cover: days_to_cover.to_f
              }

            rescue StandardError => e
              puts "Error processing - #{e}"
              next
            end
          end.compact
        end

        private

        def data_rows
          @data_rows ||= short_interest_table.css('tr').map { |tr| tr.css('td').map { |td| td.text } }
        end

        def short_interest_table
          @short_interest_table = noko.css('table').select { |t| t['id'] =~ /ShortInterestGrid/ }.first
        end

        def noko
          @noko ||= Nokogiri.parse(page_html)
        end

      end
    end
  end
end