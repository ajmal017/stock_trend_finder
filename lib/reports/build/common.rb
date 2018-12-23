module Reports
  module Build
    module Common
      def convert_hash_keys(pg_result)
        new_report = []
        pg_result.each do |row|
          new_report << {
            snapshot_time:  row['snapshot_time'],
            updated_at:     row['updated_at'],
            gray_symbol:    row['gray_symbol']=='t',

            ticker_symbol:    row['ticker_symbol'],
            last_trade:       row['last_trade'].try(:to_f),
            change_percent:   row['change_percent'].try(:to_f),
            gap_percent:                      row['gap_percent'].try(:to_f),
            percent_above_52_week_high:       row['percent_above_52_week_high'].try(:to_f),
            outside_52_week_range:            row['outside_52_week_range'].present? ? row['outside_52_week_range']=='t' : nil,
            short_days_to_cover:              row['short_days_to_cover'].try(:to_f),
            short_percent_of_float:           row['short_percent_of_float'].try(:to_f),
            institutional_ownership_percent:  row['institutional_ownership_percent'].try(:to_f),
            float:                            row['float'].try(:to_f),
            float_percent_traded:             row['float_percent_traded'].try(:to_f),
            dividend_yield:             row['dividend_yield'].try(:to_f),
            sp500:            row['sp500']=='t',
            volume:           row['volume'].try(:to_f),
            volume_average:   row['volume_average'].try(:to_f),
            volume_ratio:     row['volume_ratio'].try(:to_f),
          }
        end
        new_report
      end

      def run_query(qry)
        ActiveRecord::Base.connection.execute(qry)
      end
    end
  end
end