module Reports
  module Build
    module Sections
      class Gaps
        include Verbalize::Action

        attr_reader :sections

        input :report

        def call
          @sections = []

          @sections << {
            title: 'Bullish Gaps',
            line_items: ReportPresenter.format(@report.select { |r| r[:gap_percent] >= 0.0 })
          }

          @sections << {
            title: 'Bearish Gaps',
            line_items: ReportPresenter.format(@report.select { |r| r[:gap_percent] < 0.0 })
          }

          sections
        end


      end
    end
  end
end