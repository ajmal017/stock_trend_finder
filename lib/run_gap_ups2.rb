#Strategy #2-revision2 -run against the Russell 3000 as of 12/10/13
# Alert on gap up > 1.75%
# Stop loss:
#   Day 1:
#     0.955
#     If price reaches 1.04 of open price, raise stop loss to trailing 1.025
#   Day 2:
#     0.975
#     If price reaches 1.04, raise stop loss to trailing 1.025
#   Day 3+:
#     Stop Loss = Greater of(0.99 of low from 2 days ago, 0.99 of original open)
#   Sell after 10 days if not above 4%
#
# * Close out position at previous close price in event of a split


STRATEGY_NUMBER=2

TradePosition.delete_all

Ticker.russell3000.each do |t|
  dsp_cache = t.daily_stock_prices.order(:price_date).to_a
  splits=t.stock_splits.map(&:split_date) || []

  gap_ups = t.gap_ups.order(:price_date)
  gap_ups.each do |gap|
      # skip over this gap up if you are still HOLDing from the previous gap up
      next if TradePosition.where(ticker_symbol: gap.ticker.symbol, trade_date: gap.price_date).present?

      # Initiate a buy position on the day of the gap up
      gap.trade_positions.create(
          ticker_symbol: gap.ticker.symbol,
          trade_date: gap.price_date,
          position: "BUY",
          value: 1,
          price: gap.open
      )
      status = :bought

      # get a cache of all prices going forward
      prices = dsp_cache.slice(dsp_cache.index {|dsp| dsp.price_date==gap.price_date}..dsp_cache.count)

      ActiveRecord::Base.transaction do
        # run through all of the subsequent pricing days and decide how to trade this
        prices.each.with_index(1) do |q, day|
          open = q.open
          high = q.high
          low = q.low
          close = q.close
          price_date = q.price_date

          # set your stop losses for each day
          case day
            when 1 then
              stop_loss = gap.open * 0.955
            when 2 then
              stop_loss = gap.open * 0.965
            else # day 3 or more
              stop_loss = [(gap.open * 0.975), prices[day-3].low * 0.98, prices[day-2].low * 0.98].max
          end

          # set a higher stop loss if we have a 1-day reversal (stock goes really high and triggers a trailing stop loss)
          if high / open > 1.045
            stop_loss = (high * 0.985).round(2)
          end

          # stop loss was triggered today
          if low < stop_loss
            gap.trade_positions.create!(
                ticker_symbol: gap.ticker.symbol,
                trade_date: price_date,
                position: "SELL",
                value: ([high, stop_loss].min / gap.open).round(3),
                price: [high, stop_loss].min,
                reason: "stop loss"
            )
            status = :sold
            break
          end


          if (day > 10) && (open < gap.open * 1.04)
            gap.trade_positions.create!(
                ticker_symbol: gap.ticker.symbol,
                trade_date: price_date,
                position: "SELL",
                value: (open / gap.open).round(3),
                price: open,
                reason: "day > 10"
            )
            status = :sold
            break
          end

          if splits.index(price_date)
            gap.trade_positions.create!(
                ticker_symbol: gap.ticker.symbol,
                trade_date: price_date,
                position: "SELL",
                value: (prices[day-2].open / gap.open).round(3),
                price: prices[day-2].open,
                reason: "split"
            )
            status = :sold
            break
          end

          gap.trade_positions.create!(
              ticker_symbol: gap.ticker.symbol,
              trade_date: price_date,
              position: "HOLD",
              value: (close / gap.open).round(3),
              price: close
          )
        end

      end
  end

end



# iterate list of price gaps by date

# report X companies have gapped up today, list tickers. take positions? __
# unless "no" or "N"
# retrieve list of tickers to take positions (no more than 5)
# foreach ticker
# if ticker says "void tickername", then take it off watch list it
# set initial stop loss points
# log "BUY" transaction - number of shares and money
# iterate through each day prices (get the daily price movement associated with ticker .each)
# stop loss triggered?
# number log day number
# log "SELL" transaction - number of shares and money and profit
