module TDAmeritradeDataInterface

  def self.next_vix_futures_symbol(current_date=Date.today)
    f=File.join(Dir.pwd, 'downloads', 'vix_expiration_dates.csv')
    File.open(f) do |f|
      f.any? do |line|
        date_string,symbol = line.split(',')
        month,day,year = date_string.split('/')
        last_expiration_date = Date.new(year.to_i, month.to_i, day.to_i)

        return symbol.strip if current_date <= last_expiration_date
      end
    end
    return nil
  end


end