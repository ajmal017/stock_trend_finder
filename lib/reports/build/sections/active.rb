module Reports
  module Build
    module Sections
      class Active
        include Verbalize::Action

        attr_reader :sections

        input :report

        def call
          @sections = []

          @sections << {
            title: 'Gainers',
            line_items: ReportPresenter.format(@report.select { |r| r[:change_percent] >= 0.0 })
          }

          @sections << {
            title: 'Losers',
            line_items: ReportPresenter.format(@report.select { |r| r[:change_percent] < 0.0 })
          }

          sections
        end


      end
    end
  end
end