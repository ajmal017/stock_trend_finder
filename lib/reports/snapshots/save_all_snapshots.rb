module Reports
  module Snapshots
    class SaveAllSnapshots
      include Verbalize::Action

      REPORTS = [
        :active,
        :after_hours,
        :fifty_two_week_high,
        :fifty_two_week_low,
        :gaps,
        :premarket
      ]

      def call
        REPORTS.each do |rt|
          Reports::Snapshots::Create.call(report_type: rt, report_date: Date.today)
        end
      end

    end
  end
end