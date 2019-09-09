require 'market_data_utilities/ticker_list/line_item_filter'

module MarketDataUtilities
  module TickerList
    class ImportNasdaqCompanyLists
      include Verbalize::Action

      attr_reader :line_items

      EXCHANGES=%w(nyse nasdaq amex)

      input :date

      def call
        validate_files_exist
        @line_items = []

        files_to_import.each do |file_detail_hash|
          csv_data = CSV.open(file_detail_hash[:file], headers: true)
          csv_data.each do |line|
            @line_items << {
              symbol:       line['Symbol'],
              company_name: line['Name'],
              exchange:     file_detail_hash[:exchange],
              market_cap:   line['MarketCap'], # no longer capturing market cap; getting it from TD Ameritrade
              sector:       line['Sector'],
              industry:     line['industry']
            }
          end
        end

        MarketDataUtilities::TickerList::InsertLineItems.(
          input: MarketDataUtilities::TickerList::LineItemFilter.run_all(line_items)
        ).value
      end

      private

      def files_to_import
        @files_to_import ||= EXCHANGES.map do |exchange|
          {
            exchange: exchange,
            file: File.join(STOCK_TREND_FINDER_DATA_DIR, 'nasdaq_company_lists', "companylist-#{date.strftime('%Y%m%d')}-#{exchange}.csv")
          }
        end
      end

      def validate_files_exist
        unless files_to_import.all? { |h| File.exists?(h[:file]) }
          raise "Couldn't find the expected file #{h[:file]}"
        end
      end

    end
  end
end