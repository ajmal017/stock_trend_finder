#Strategy #1:
# Alert on gap up > 2%
# Initial stop loss: 4%
# Sell earlier for 10 days or 8% gain
# XXXX Reset stop loss at 3%, 7%, 10%, 15%, 20%, 25%, 30% of initial gap open

STRATEGY_NUMBER=1

def gap_in_forbidden_dates(d)
  (Date.new(2001,9,11)..Date.new(2003,3,11)).cover?(d) || (Date.new(2008,9,17)..Date.new(2009,3,8)).cover?(d)
end


Ticker.tracking_gap_ups.each do |ticker|
  GapUp.where(ticker_id: ticker.id).order(price_date: :asc).each do |gap|
    next if gap_in_forbidden_dates(gap.price_date)
    next if gap.trade_positions.where(trade_date: gap.price_date).count > 0

    stop_loss = gap.open * 0.96
    target = gap.open * 1.08

    # Initiate a buy position
    gap.trade_positions.create(
        trade_date: gap.price_date,
        position: "BUY",
        value: 100,
        price: gap.open
    )
    status = :bought

    prices=gap.ticker.daily_stock_prices
    prices=prices.where(prices.arel_table[:price_date].gt(gap.price_date)).order(price_date: :asc).first(9)

    prices.each do |daily_quote|
      if daily_quote[:high] > target
        gap.trade_positions.create(
            trade_date: daily_quote[:price_date],
            position: "SELL",
            value: 100 * [daily_quote[:low], target.to_d].max / gap.open,
            price: [daily_quote[:low], target.to_d].max
        )
        status = :sold
        break
      end

      if daily_quote[:low] < stop_loss
        gap.trade_positions.create(
            trade_date: daily_quote[:price_date],
            position: "SELL",
            value: 100 * [daily_quote[:high], stop_loss].min / gap.open,
            price: [daily_quote[:high], stop_loss].min
        )
        status = :sold
        break
      end

      gap.trade_positions.create(
          trade_date: daily_quote[:price_date],
          position: "HOLD",
          value: 100 * daily_quote[:close] / gap.open,
          price: daily_quote[:close]
      )
    end

    unless status == :sold
      gap.trade_positions.last.update(
          position: "SELL"
      )
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




#STRATEGY_NUMBER=2
#
#def gap_in_forbidden_dates(d)
#  #(Date.new(2001,9,11)..Date.new(2003,3,11)).cover?(d) || (Date.new(2008,9,17)..Date.new(2009,3,8)).cover?(d)
#  false # no forbidden dates
#end
#
#
#Ticker.tracking_gap_ups.each do |ticker|
#  GapUp.where(ticker_id: ticker.id).order(price_date: :asc).each do |gap|
#    next if gap_in_forbidden_dates(gap.price_date)
#    next if gap.trade_positions.where(trade_date: gap.price_date).count > 0
#
#    # Set the initial stop loss point and where to bump up the trailing stop loss
#    stop_loss = gap.open * 0.96
#    stop_loss_reset = gap.open * 1.04
#
#    # Initiate a buy position on the day of the gap up
#    gap.trade_positions.create(
#        trade_date: gap.price_date,
#        position: "BUY",
#        value: 1,
#        price: gap.open
#    )
#    status = :bought
#
#    prices=gap.ticker.daily_stock_prices
#    prices=prices.where(prices.arel_table[:price_date].gt(gap.price_date)).order(price_date: :asc).first(100)
#
#    prices.each.with_index do |daily_quote, index|
#      if daily_quote[:low] < stop_loss
#        gap.trade_positions.create(
#            trade_date: daily_quote[:price_date],
#            position: "SELL",
#            value: [daily_quote[:high], stop_loss].min / gap.open,
#            price: [daily_quote[:high], stop_loss].min
#        )
#        status = :sold
#        break
#      end
#
#      if daily_quote[:high] > stop_loss_reset
#        stop_loss=stop_loss_reset
#      end
#
#      gap.trade_positions.create(
#          trade_date: daily_quote[:price_date],
#          position: "HOLD",
#          value: daily_quote[:close] / gap.open,
#          price: daily_quote[:close]
#      )
#
#      if index > 2 # changed this from 1
#                   #stop_loss = [stop_loss, stop_loss_reset, [(prices[index-2][:low]*0.99)].max  # Reset the stop loss
#        stop_loss = [stop_loss, [stop_loss_reset,prices[index-2][:low],prices[index-1][:low]]].min*0.99].max  # Reset the stop loss
#      else
#        stop_loss = [stop_loss, stop_loss_reset].max  # Reset the stop loss
#      end
#    end
#
#    unless status == :sold
#      gap.trade_positions.last.update(
#          position: "SELL"
#      )
#    end
#
#  end