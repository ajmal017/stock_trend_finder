class ReportReview < ActiveRecord::Base

  def self.log_review(report_type, report_date)
    review = self.find_or_create_by!(report_type: report_type, report_date: report_date)
    review.update(reviewed_date: Date.current)
  end

  def self.report_reviewed_date(report_type, report_date)
    self.find_by(report_type: report_type, report_date: report_date)&.reviewed_date
  end
end
