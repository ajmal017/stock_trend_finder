require 'market_data_utilities/file_utilities'

class VIXFuturesCBOEHistoricalDataPull
  include FileUtilities

  def download_data(begin_month: 5, begin_year: 2004, end_month: 8, end_year: 2015)
    (begin_year..end_year).each do |year|
      (1..12).each do |month|
        next if begin_year && (month < begin_month)
        next if end_year && (month > end_month)

        begin
          download_file(build_remote_data_file_name(month, year), build_local_file_name(month, year))
        rescue
          puts "Couldn't download #{build_remote_data_file_name(month, year)}"
        end

      end
    end
  end

  private

  def build_remote_data_file_name(month, year)
    month_code = VIXFuturesHistory::FUTURES_MONTH_LETTERS[month - 1]
    year_code = year.to_s.chars.pop(2).join
    "http://cfe.cboe.com/Publish/ScheduledTask/MktData/datahouse/CFE_#{month_code}#{year_code}_VX.csv"
  end

  def build_local_file_name(month, year)
    File.join(downloads_folder, 'cboe_vx_historical', "vx-#{year}-#{month.to_s.rjust(2, "0")}.csv")
  end
end