module Reports
  module Build
    class TickerList
      include MarketDataUtilities::MoneyAsString
      include Reports::Build::Common
      include Reports::Build::SQL
      include Verbalize::Action

      input :report_date

      def call
        convert_hash_keys(report.to_a)
      end

      private

      def convert_date(date_str)
        return nil if date_str.nil?
        Date.parse(date_str).strftime('%Y-%m-%d')
      end

      def convert_hash_keys(pg_result)
        new_report = []
        pg_result.each do |row|
          new_report << {
            id: row['id'],
            gray_symbol:      row['scrape_data']=='f',
            ticker_symbol:    row['symbol'],
            company_name:     row['company_name'],
            exchange:         row['exchange'],
            scrape_data:      row['scrape_data']=='t',
            sector:           row['sector'],
            industry:         row['industry'],
            market_cap:       human_readable(row['market_cap'].try(:to_f), 2, as: :billions),
            date_modified:    convert_date(row['date_modified']),
            last_action:      row['last_action'],
            most_recent_price: row['most_recent_price'],
            sp500:            row['sp500']=='t',
          }
        end
        new_report
      end

      def report
        @report ||= run_query(
          select_tickers_report
        )
      end

    end
  end
end