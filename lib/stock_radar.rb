module StockRadar
  class << self
    def update_stock_quotes_timer
      scheduler = Rufus::Scheduler.new

      scheduler.in '1s' do
        Ticker.tracking_gap_ups.each do |ticker|
          begin
            ticker.update_daily_stock_prices
          rescue Exception => e
            puts "Error updating #{ticker.symbol}\n" + e.message + e.backtrace.join("\n")
          end
        end
      end

      scheduler.join
    end

    def parse_thinkorswim_list(file_name)
      puts "Screening List of Tickers For Gap Ups >1.5%..."
      input_file = File.join(Rails.root, 'lib', 'thinkorswim_export', file_name)
      lines = open(input_file).readlines

      gap_ups = Array.new
      not_tracking = Array.new
      not_gap = Array.new
      unknown = Array.new

      lines.shift until lines.first.match(/Symbol/)
      lines.shift

      lines.each do |line|
        symbol,mark,chg,trend=line.split(',')
        if Ticker.exists?(symbol: symbol)
          ticker = Ticker.find_by(symbol:symbol)
          if ticker.track_gap_up
            pct_chg = (mark.to_d / DailyStockPrice.find_by(ticker_symbol: symbol).high).round(2)
            if pct_chg > 1.015
              gap_ups << "#{symbol.ljust(5)} #{ticker.company_name.ljust(25)[0..24]} (#{pct_chg}), #{ticker.industry}"
            else
              not_gap << "#{symbol.ljust(5)} #{ticker.company_name.ljust(25)[0..24]} (#{pct_chg}), #{ticker.industry}"
            end
          else
            not_tracking << "#{symbol.ljust(5)} #{ticker.company_name}"
          end
        else
          unknown << "#{symbol.ljust(5)}, #{mark}, #{chg}"
        end
      end


      puts "Gap Ups:"
      puts gap_ups
      puts "\n\nNot Gaps:"
      puts not_gap
      puts "\n\nNot Tracking:"
      puts not_tracking
      puts "\n\nUnknown:"
      puts unknown

#      db_read_file = open(db_read_file_path, 'w')

 #     db_read_file.write("ticker_id,price_date,open,high,low,close,volume\n")



    end

  end
end