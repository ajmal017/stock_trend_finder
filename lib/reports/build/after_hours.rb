module Reports
  module Build
    class AfterHours
      include Reports::Build::Common
      include Reports::Build::SQL
      include Verbalize::Action

      input :report_date

      def call
        convert_hash_keys(report_percent.to_a + report_volume.to_a)
      end

      private

      def report_percent
        @report_percent ||= run_query(
          select_after_hours_by_percent(report_date),
        )
      end

      def report_volume
        @report_volume ||= run_query(
          select_after_hours_by_volume(report_date),
        )
      end

    end
  end
end