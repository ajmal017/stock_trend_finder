require 'tdameritrade_data_interface/tdameritrade_data_interface'

class ReportsController < ApplicationController

  def hide_symbol
    @symbol = params[:symbol]
    Ticker.find_by(symbol: @symbol).hide_from_reports
  end

  def unscrape_symbol
    @symbol = params[:symbol]
    Ticker.unscrape(@symbol)
  end

  def ema13_breaks
    @report = run_query(TDAmeritradeDataInterface.select_ema13_bullish_breaks)
  end

  def hammers
    @report = run_query(TDAmeritradeDataInterface.select_hammers)
  end

  def active_stocks
    @report = run_query(TDAmeritradeDataInterface.select_active_stocks)
  end

  def candle_row
    @report_winners = run_query(TDAmeritradeDataInterface.select_4_green_candles)
    @report_losers = run_query(TDAmeritradeDataInterface.select_4_red_candles)

  end

  def pctgainloss
    @report_winners = run_query(TDAmeritradeDataInterface.select_10pct_gainers)
    @report_losers = run_query(TDAmeritradeDataInterface.select_10pct_losers)
  end

private
  def run_query(qry)
    ActiveRecord::Base.connection.execute qry
  end
end
