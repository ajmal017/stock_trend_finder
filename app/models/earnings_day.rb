require 'market_data_utilities/datetime_utilities'

class EarningsDay < ActiveRecord::Base
  extend DateTimeUtilities

  # Loads a list of all the earnings expected for the current day and serializes it in the database
  def self.load_list(text, date=Date.today)
    parsed_earnings = Briefing::EarningsParser.parse_earnings(text)

    if parsed_earnings[:after_close_today]
      EarningsDay.create(
            before_the_open: false,
            earnings_date: date,
            tickers: parsed_earnings[:after_close_today].gsub(' ', '')
      )
    end

    if parsed_earnings[:before_open_tomorrow]
      EarningsDay.create(
          before_the_open: true,
          earnings_date: next_market_day(date),
          tickers: parsed_earnings[:before_open_tomorrow].gsub(' ', '')
      )
    end
  end

  def self.load_before_list(text, date=Date.today+1, separator=',')
    EarningsDay.create(
      before_the_open: true,
      earnings_date: date,
      tickers: separator==',' ? text.gsub(' ', '') : text.gsub(/\s/, ',')
    )
  end

  def self.load_after_list(text, date=Date.today, separator=',')
    EarningsDay.create(
      before_the_open: false,
      earnings_date: date,
      tickers: separator==',' ? text.gsub(' ', '') : text.gsub(/\s/, ',')
    )
  end
end