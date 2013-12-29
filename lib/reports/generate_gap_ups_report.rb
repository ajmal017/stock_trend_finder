class ReportStats
  attr_accessor :splits_skipped, :eclipsed_gap_ups_skippped, :gap_ups_processed, :splits

  def initialize
    @splits_skipped=0
    @eclipsed_gap_ups_skippped=0
    @gap_ups_processed=0
    @splits = []
  end

  def self.contains_a_split(prices)
    puts @splits
    if @splits.count > 0
      false
    else
      @splits.inject(false) { |r,s| prices.map(&:price_date).index(s).present? || r }
    end
  end
end

stats = ReportStats.new
output_file = open(File.join(Rails.root, 'lib', 'gap_up_report.csv'), 'w')
header = "id|ticker|price_date|open|d10|d9|d8|d7|d6|d5|d4|d3|d2|u2|u3|u4|u5|u6|u7|u8|u9|u10|peak_day|peak_pct|bottom_day|bottom_pct|finish|finish_pct|first_day_pct_move|first_day_down|first_day_gap_close|pct_of_52_week_high|yahoo_chart\n"
output_file.write(header)

Ticker.russell3000.each do |t|
  dsp_cache = t.daily_stock_prices.order(:price_date).to_a
  prices=Array.new # used to hold the next 20 days of pricing day for the currently processed gap
  stats.splits=t.stock_splits.map(&:split_date) || []

  gap_ups = t.gap_ups.order(:price_date).where(Arel::Table.new(:gap_ups)[:price_date].lt(Date.new(2013,11,1)))
  gap_ups.each do |gap|
    # ignore this gap up if the last gap up date we processed contains this date
    if prices.inject(false) { |r,p| (p.price_date==gap.price_date) || r }
      stats.eclipsed_gap_ups_skippped += 1
      next
    end

    prices = dsp_cache.slice(dsp_cache.index {|dsp| dsp.price_date==gap.price_date}, 20)
    if ReportStats.contains_a_split(prices) # Don't worry about adjusting for splits, just skip em
      stats.splits_skipped += 1
      next
    end

    r = {
        id: gap.id,
        ticker: gap.ticker_symbol,
        price_date: gap.price_date,
        open: gap.open,
        d10: nil,
        d9: nil,
        d8: nil,
        d7: nil,
        d6: nil,
        d5: nil,
        d4: nil,
        d3: nil,
        d2: nil,
        u2: nil,
        u3: nil,
        u4: nil,
        u5: nil,
        u6: nil,
        u7: nil,
        u8: nil,
        u9: nil,
        u10: nil,
        peak_day: 1,
        peak_pct: nil,
        bottom_day: 1,
        bottom_pct: nil,
        finish: prices.last.close,
        finish_pct: (prices.last.close / gap.open).round(2),
        first_day_pct_move: (prices.first.close/prices.first.open).round(2),
        first_day_down: gap.close < gap.open,
        first_day_gap_close: gap.low < gap.previous_high,
        pct_of_52_week_high: gap.pct_of_last_year_close,
        yahoo_chart: "http://finance.yahoo.com/echarts?s=#{gap.ticker_symbol}+Interactive#symbol=#{gap.ticker_symbol};range=#{gap.price_date.year-1}#{gap.price_date.month.to_s.rjust(2, '0')}#{gap.price_date.day.to_s.rjust(2,'0')},#{gap.price_date.year}#{gap.price_date.month.to_s.rjust(2, '0')}#{gap.price_date.day.to_s.rjust(2,'0')};compare=;indicator=split+dividend+ud+volume;charttype=candlestick;crosshair=on;ohlcvalues=1;logscale=off;source=undefined;",
        chart_link: nil,
        gap_up_strength: gap.previous_high ? (gap.open/gap.previous_high).round(3) : nil
    }

    high = 0
    low = 1000000000
    prices.each.with_index(1) do |dp, day|
      if dp.high > high
        high = dp.high
        r[:peak_day] = day
        r[:peak_pct] = (dp.high / gap.open).round(2)
      end
      if dp.low < low
        low = dp.low
        r[:bottom_day] = day
        r[:bottom_pct] = (dp.low / gap.open).round(2)
      end

      r[:d10] ||= (dp.low / gap.open <= 0.90 ? day : nil)
      r[:d9] ||= (dp.low / gap.open <= 0.91 ? day : nil)
      r[:d8] ||= (dp.low / gap.open <= 0.92 ? day : nil)
      r[:d7] ||= (dp.low / gap.open <= 0.93 ? day : nil)
      r[:d6] ||= (dp.low / gap.open <= 0.94 ? day : nil)
      r[:d5] ||= (dp.low / gap.open <= 0.95 ? day : nil)
      r[:d4] ||= (dp.low / gap.open <= 0.96 ? day : nil)
      r[:d3] ||= (dp.low / gap.open <= 0.97 ? day : nil)
      r[:d2] ||= (dp.low / gap.open <= 0.98 ? day : nil)
      r[:u2] ||= (dp.high / gap.open >= 1.02 ? day : nil)
      r[:u3] ||= (dp.high / gap.open >= 1.03 ? day : nil)
      r[:u4] ||= (dp.high / gap.open >= 1.04 ? day : nil)
      r[:u5] ||= (dp.high / gap.open >= 1.05 ? day : nil)
      r[:u6] ||= (dp.high / gap.open >= 1.06 ? day : nil)
      r[:u7] ||= (dp.high / gap.open >= 1.07 ? day : nil)
      r[:u8] ||= (dp.high / gap.open >= 1.08 ? day : nil)
      r[:u9] ||= (dp.high / gap.open >= 1.09 ? day : nil)
      r[:u10] ||= (dp.high / gap.open >= 1.10 ? day : nil)
    end

    output_file.write(r.values.join('|') + "\n")
    stats.gap_ups_processed += 1
  end
end
output_file.close

puts "Gap Ups Processed:      #{stats.gap_ups_processed}"
puts "Skipped due to eclipse: #{stats.eclipsed_gap_ups_skippped}"
puts "Skipped due to split:   #{stats.splits_skipped}"