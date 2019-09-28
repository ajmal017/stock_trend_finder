module Reports
  module Build
    class Industry
      include MarketDataUtilities::MoneyAsString
      include Reports::Build::Common
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
            bucket_type: row['bucket_type'],
            bucket: row['bucket'],
            market_cap: human_readable(row['market_cap'].try(:to_f), 0, as: :trillions),
            change_pct_1_day: row['change_pct_1_day'],
            change_pct_10_day: row['change_pct_10_day'],
            change_pct_30_day: row['change_pct_30_day'],
            change_pct_90_day: row['change_pct_90_day']
          }
        end
        new_report
      end

      def query
        <<~SQL
          select * 
          from market_cap_aggregations 
          where price_date='#{report_date.strftime('%Y-%m-%d')}' 
          order by bucket_type desc, market_cap desc
        SQL
      end

      def report
        @report ||= run_query(query)
      end

    end
  end
end