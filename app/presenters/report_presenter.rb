# Note: I havent' deployed this class into full use yet. I plan to use it by Ryan Bates' example in this Railscast:
# http://railscasts.com/episodes/287-presenters-from-scratch?view=asciicast
#
# The only functionality currently being used is #display_short
#

class ReportPresenter
  def initialize(report)
    @report = report
  end

  def self.display_short(days_to_cover, float_pct)
    if days_to_cover && float_pct
      days_to_cover.rjust(5) + " | " + float_pct.rjust(3).gsub(' ', '&nbsp;') + "%"
    else
      ""
    end
  end

end