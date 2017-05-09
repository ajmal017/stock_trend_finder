module Briefing
  class EarningsParser
    def self.parse_earnings(text)
      result = {}
      m = text.match /after the close.*:\n(.*)\n/
      result[:after_close_today] = m[1].gsub(', among others', '') if m

      m = text.match /before the open.*:\n(.*)\n/
      result[:before_open_tomorrow] =  m[1].gsub(', among others', '') if m

      result
    end
  end
end