module TDAmeritradeDataInterface

  def self.next_vix_futures_symbol(current_date=Date.today)
    File.open(vix_futures_expirations_file) do |f|
      f.any? do |line|
        last_expiration_date, symbol = process_line(line)
        return symbol if current_date <= last_expiration_date # last_expiration_date = last day that future can be traded
      end
    end
    return nil # only if we went through the whole file and no future date was populated
  end

  # Takes a given day and gives the previous VIX futures expiration date and the upcoming one
  # Output: [previous_expiration_date, next_expiration_date]
  def self.surrounding_vix_futures_expirations(date=Date.today)
    previous_exp = next_exp = nil
    File.open(vix_futures_expirations_file) do |f|
      while line = f.readline()
        next_exp, symbol = process_line(line)
        if date <= next_exp
         break
        else
          previous_exp = next_exp
        end
      end
    end
    [previous_exp, next_exp]
  end

  def self.days_to_vix_expiration
    market_days_between(Date.today, surrounding_vix_futures_expirations(Date.today)[1])
  end

  def self.vix_futures_term_days
    begin_day, end_day = surrounding_vix_futures_expirations(Date.today)
    market_days_between(begin_day, end_day)
  end

  private

  # The expirations file should be a hash of data:
  # expiration date,symbol
  #
  # Example:
  # 4/18/2015,^VIXAPR
  # 5/20/2015,^VIXMAY
  # 6/16/2015,^VIXJUN
  # 7/22/2015,^VIXJUL
  #
  def self.vix_futures_expirations_file
    File.join(Dir.pwd, 'downloads', 'vix_expiration_dates.csv')
  end

  # Processes a line in the VIX expirations file
  #
  # Input:  "4/18/2015,^VIXAPR"
  # Output: [<Date: 2015-04-18>, "^VIXAPR"]
  def self.process_line(line_text)
    date_string,symbol = line_text.split(',')
    month,day,year = date_string.split('/')
    [Date.new(year.to_i, month.to_i, day.to_i), symbol.strip]
  end
end