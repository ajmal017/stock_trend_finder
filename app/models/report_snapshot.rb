class ReportSnapshot < ActiveRecord::Base
  has_many :report_snapshot_line_items
end
