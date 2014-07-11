output_file = open(File.join(Rails.root, 'lib', 'hammer_report.csv'), 'w')
header = "ticker|day|body_wick_ratio\n"
output_file.write(header)


Ticker.tracking_gap_ups.each do |ticker|
  puts "Looking at #{ticker.symbol}"
  #next if DailyStockPrice.where{(ticker_id.eq(ticker)) & price_date == '2014-02-13'}.first.close < 6

  consecutive_count=0
  last_high=0
  RealTimeQuote.where{
    (ticker_id.eq(ticker))
  }.each  do |daily_bar|

    open = daily_bar.open - daily_bar.low   #12.65 : 0.21
    high = daily_bar.high - daily_bar.low   #12.70 : 0.26
    low = 0 #daily_bar.low - daily_bar.low  #12.44 : 0
    last = daily_bar.last_trade - daily_bar.low #12.69 : 0.25

    body = (open - last).abs        # 0.04
    body_top = [open, last].max     # 0.25
    body_bottom = [open, last].min  # 0.21

    #range = high - low # 0.22
    upper_range = high - body_top    # 0.01
    lower_range = body_bottom - low  # 0.25


    body_wick_ratio = (body == 0 ? 0 : body / [upper_range, lower_range].max).round(2)  # 0.04 / 0.25 = 0.16
    body_top_pct = (last == 0 ? 0 : body_top / high)                                   # 0.961
    body_bottom_pct = (open == 0 ? 0 : body_bottom / high)                              # 0.087

    if (body_wick_ratio < 0.34) && ((body_top_pct > 0.95) || (body_bottom_pct < 0.05))
      output_file.write("#{daily_bar.ticker_symbol}|#{Date.today.strftime("%m/%d/%Y")}|#{body_wick_ratio}\n")
    end
  end


end

output_file.close