module Reports
  module Build
    module Sections
      class FiftyTwoWeekLow
        include Verbalize::Action

        attr_reader :sections

        input :report

        def call
          @sections = []

          @sections << {
            title: nil,
            line_items: ReportPresenter.format(@report)
          }

          sections
        end


      end
    end
  end
end