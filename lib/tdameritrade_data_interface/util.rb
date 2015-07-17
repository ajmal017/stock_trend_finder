module TDAmeritradeDataInterface
  def self.is_market_day?(day)
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
  def self.market_days_between(begin_day, end_day)
    days_between=0
    f=File.join(Dir.pwd, 'downloads', 'market_days.csv')
    File.open(f) do |f|
      f.any? do |line|
        line_date = Date.parse(line.strip)
        if line_date > begin_day && line_date <= end_day
          days_between += 1
        else
          return days_between if days_between > 0
        end
      end
    end
    days_between
  end

  def self.time_strip_date(time)
    time.to_r / 86400 % 1
  end

  def self.time_strip_time_zone(time)
    Time.parse(time.strftime('%a, %d %b %Y %H:%M:%S'))
  end

  def self.compare_time(time1, time2)
    (time1.to_r / 86400) % 1 <=> (time2.to_r / 86400) % 1
  end

end