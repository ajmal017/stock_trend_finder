class ReportReview < ActiveRecord::Base

  def self.log_review(report_type, report_date)
    review = self.find_or_create_by!(report_type: report_type, report_date: report_date)
    review.update(reviewed_date: Date.current)
  end

  def self.report_reviewed_date(report_type, report_date)
    self.find_by(report_type: report_type, report_date: report_date)&.reviewed_date
  end

  def self.list_by_date(as_of_date=Date.current)
    dates = ((as_of_date-60.days)..(as_of_date)).select { |date| StockMarketDays.is_market_day?(date) }
    all_reviews = ReportReview.where('reviewed_date >= ? ', dates.min)


    dates.map do |date|
      {
        date: date,
        week52_highs: all_reviews.find { |r| r.report_date == date && r.report_type.to_sym == :week52_highs }&.reviewed_date || false,
        week52_lows: all_reviews.find { |r| r.report_date == date && r.report_type.to_sym == :week52_lows }&.reviewed_date || false,
        active_stocks: all_reviews.find { |r| r.report_date == date && r.report_type.to_sym == :active_stocks }&.reviewed_date || false,
      }
    end
  end
end
