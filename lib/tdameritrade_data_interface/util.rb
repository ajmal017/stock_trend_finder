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