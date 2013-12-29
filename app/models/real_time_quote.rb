class RealTimeQuote < ActiveRecord::Base
  belongs_to :ticker

  def self.reset_cache
    ActiveRecord::Base.connection.execute(
        "TRUNCATE TABLE real_time_quotes"
    )
  end

  def self.import_gap_up_list(file_name, quote_time=Time.now)
    RealTimeQuote.reset_cache
    file_path = File.join(Rails.root, 'lib', 'thinkorswim_export', file_name)
    if File.exists? file_path
      gap_up_file = open(file_path)
      gap_up_file_lines = gap_up_file.readlines
      gap_up_file.close

      if gap_up_file_lines.length > 0
        gap_up_file_lines.shift until gap_up_file_lines[0].match(/^Symbol/)
        gap_up_file_lines.shift

        gap_up_file_lines.each do |line|
          puts "Processing line '#{line}'"
          symbol,mark,pct_change,strength_meter=line.split(',')
          ticker = Ticker.find_by(symbol: symbol)
          if ticker
            RealTimeQuote.create(
              ticker_id: ticker.id,
              ticker_symbol: symbol,
              open: mark,
              last_trade: mark,
              quote_time: quote_time
            )
          else
            puts "Cant find ticker #{symbol}"
          end
        end
      end
    end
  end
end
