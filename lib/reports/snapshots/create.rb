module Reports
  module Snapshots
    class Create
      include Verbalize::Action

      REPORT_FIELDS = [
        :ticker_symbol,
        :last_trade,
        :change_percent,
        :volume,
        :volume_average,
        :volume_ratio,
        :short_days_to_cover,
        :short_percent_of_float,
        :float,
        :float_percent_traded,
        :dividend_yield,
        :institutional_ownership_percent,
        :gap_percent,
        :percent_above_52_week_high,
        :percent_below_52_week_low,
        :market_cap,
        :week_52_streak,
        :days_active
      ]

      input :report_type, :report_date

      def call
        line_items = "Reports::Build::#{report_type.to_s.camelcase}".constantize.call(report_date: report_date).value
        return if line_items.empty?

        line_items.each do |li|
          report_snapshot.report_snapshot_line_items.build(li.slice(*REPORT_FIELDS))
        end

        report_snapshot.save
      end

      private

      def report_snapshot
        @report_snapshot ||= ReportSnapshot.new(
          built_at: Time.current,
          report_type: report_type
        )
      end

    end
  end
end