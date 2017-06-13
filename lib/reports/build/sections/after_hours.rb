module Reports
  module Build
    module Sections
      class AfterHours
        include Verbalize::Action

        attr_reader :sections

        input :report

        def call
          @sections = []

          @sections << {
            title: 'Up, By Average Volume',
            line_items: ReportPresenter.format(@report.select { |r| r[:change_percent].to_f >= 0.0 })
          }

          @sections << {
            title: 'Down, By Average Volume',
            line_items: ReportPresenter.format(@report.select { |r| r[:change_percent] < 0.0 })
          }
          sections
        end


      end
    end
  end
end