module DateTimeUtilities
  def is_market_day?(day=Date.today)
    date_string = day.strftime('%-m/%-d/%y')
    market_open=false
    f=File.join(Dir.pwd, 'downloads', 'market_days.csv')
    File.open(f) do |f|
      f.any? do |line|
        market_open = true if line.strip==date_string
      end
    end
    market_open
  end

  # gets number of market days between begin_day (excluding) and end_day (including)
  def market_days_between(begin_day, end_day)
    days_between=0
    f=File.join(Dir.pwd, 'downloads', 'market_days.csv')
    File.open(f) do |f|
      f.any? do |line|
        line_date = Date.strptime(line.strip, '%m/%d/%y')
        if line_date > begin_day && line_date <= end_day
          days_between += 1
        end
        return days_between if line_date > end_day
      end
    end
    days_between
  end

  def time_strip_date(time)
    time.to_r / 86400 % 1
  end

  def time_strip_time_zone(time)
    Time.parse(time.strftime('%a, %d %b %Y %H:%M:%S'))
  end

  def compare_time(time1, time2)
    (time1.to_r / 86400) % 1 <=> (time2.to_r / 86400) % 1
  end
end

