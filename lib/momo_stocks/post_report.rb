module MomoStocks
  class PostReport
    include Verbalize::Action

    input :report_type, optional: [:report_date]

    def call
      # temporarily disabled
    
      # PostReportLineItems.(
      #   built_at: Time.now,
      #   report_date: report_date,
      #   report_type: report_type,
      #   line_items: line_items
      # )
    end

    private

    def build_class
      @build_class ||= case report_type
        when 'report_type_after_hours'
          'AfterHours'
        when 'report_type_active'
          'Active'
        when 'report_type_fifty_two_week_high'
          'FiftyTwoWeekHigh'
        when 'report_type_gaps'
          'Gaps'
        when 'report_type_premarket'
          'Premarket'
      end
    end

    def line_items
      @line_items ||= eval("Reports::Build::#{build_class}").call(report_date: report_date).value
    end

    def report_date
      @report_date || Date.current
    end

  end
end