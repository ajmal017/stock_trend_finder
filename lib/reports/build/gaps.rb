module Reports
  module Build
    class Gaps
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
          select_gaps(report_date),
        )
      end

    end
  end
end