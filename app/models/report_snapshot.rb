class ReportSnapshot < ActiveRecord::Base
  has_many :report_snapshot_line_items

  def self.last_for_day(date)
    where('date(built_at)=?', date).order(built_at: :desc).first
  end
end
