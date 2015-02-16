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
end