module Reports
  module Snapshots
    class SaveSnapshots
      include Verbalize::Action

      REPORTS = [
        :active,
        :after_hours,
        :fifty_two_week_high,
        :fifty_two_week_low,
        :gaps,
        :premarket
      ]

      input optional: [:reports]

      def call
        reports.each do |rt|
          Reports::Snapshots::Create.call(report_type: rt, report_date: Date.today)
        end
      end

      private

      def reports
        @reports || REPORTS
      end

    end
  end
end