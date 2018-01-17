module Reports
  module Build
    class FiftyTwoWeekLow # had to name it this way because numbers blow up the autoload prefixer
      include Reports::Build::Common
      include Reports::Build::SQL
      include Verbalize::Action

      input :report_date

      def call
        convert_hash_keys(report.to_a)
      end

      private

      def report
        @report ||= run_query(
          select_52_week_lows(report_date),
        )
      end

    end
  end
end