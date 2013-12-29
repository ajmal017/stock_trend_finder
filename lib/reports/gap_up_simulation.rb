simulation_start_date=Date.new(2010,1,1)
simulation_end_date=Date.new(2010,12,31)
cash=100000
invested=0
portfolio=cash
open_positions=[]

GapUpSimulationTrade.delete_all

puts "Building gap ups cache"
trade_positions_cache =
    TradePosition
    .where("price_date BETWEEN '#{simulation_start_date.to_s('%YY-%m-%d')}' AND '#{simulation_end_date.to_s('%YY-%m-%d')}' AND position='BUY'")
    .joins(:gap_up)
    .order('gap_ups.price_date', 'gap_ups.ticker_symbol')
    .map { |tp| {
        ticker_id: tp.ticker_id,
        ticker_symbol: tp.ticker_symbol,
        trade_date: tp.trade_date,
        open_price: tp.price,
        close_price: tp.close_price,
        close_date: tp.close_date,
        close_value: tp.close_value
    } }

price_dates = PriceDate.where("price_date BETWEEN '#{simulation_start_date.to_s('%YY-%m-%d')}' AND '#{simulation_end_date.to_s('%YY-%m-%d')}'").order(:price_date).pluck(:price_date)

(1..750).each do |n|
  cash=100000
  invested=0
  portfolio=cash
  open_positions=[]

  price_dates.each do |date|
    # decide how to divvy up the cash
    positions_to_open = 10 - open_positions.count
    cash_per_position = (cash / positions_to_open).floor if positions_to_open > 0

    # get all the gap ups for the day and decide which positions to open
    todays_trade_selection = trade_positions_cache.select { |trade| trade[:trade_date]==date && trade.present? }
    if todays_trade_selection.count > 0
      [positions_to_open,todays_trade_selection.count].min.times.each do
        slice_num = todays_trade_selection.count > 1 ? Random::rand(todays_trade_selection.count-1) : 0
        open_trade = todays_trade_selection.slice!(slice_num)

        puts "Open trade: #{open_trade}, #{slice_num}"

        open_positions << {
            ticker_id: open_trade[:ticker_id],
            ticker_symbol: open_trade[:ticker_symbol],
            open_date: open_trade[:trade_date],  #trade_date = opening date
            close_date: open_trade[:close_date],
            value_begin: cash_per_position,
            value_end: (open_trade[:close_value] * cash_per_position).round(2), #we are filling in the close value early and will just bump it from open_positions later
            trade_open: open_trade[:open_price],
            trade_close: open_trade[:close_price],
            simulation_id: n
        }
        cash -= cash_per_position
        invested += cash_per_position

      end
    end

    # get all the positions to close for today
    open_positions.each do |position|
      if (position[:close_date]==date) || (date==simulation_end_date)
        cash += position[:value_end]
        invested -= position[:value_begin]
        portfolio = invested + cash
        GapUpSimulationTrade.create!(
            position.merge({
                               cash: cash,
                               invested_value: invested,
                               portfolio_value: portfolio
                           })
        )
      end
    end
    open_positions = open_positions.select { |position| position[:close_date]!=date }

  end

end
