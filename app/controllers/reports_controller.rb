require 'tdameritrade_data_interface/tdameritrade_data_interface'

class ReportsController < ApplicationController
  before_filter :set_report_date

  def hide_symbol
    @symbol = params[:symbol]
    Ticker.find_by(symbol: @symbol).hide_from_reports(30)
  end

  def unscrape_symbol
    @symbol = params[:symbol]
    Ticker.unscrape(@symbol)
  end

  def ema13_breaks
    @report = run_query(TDAmeritradeDataInterface.select_ema13_bullish_breaks)
  end

  def sma50_breaks
    @report_bull50sma = run_query(TDAmeritradeDataInterface.select_sma50_bull_cross(@report_date))
    @report_bear50sma = run_query(TDAmeritradeDataInterface.select_sma50_bear_cross(@report_date))
  end

  def sma200_breaks
    @report_bull200sma = run_query(TDAmeritradeDataInterface.select_sma200_bull_cross(@report_date))
    @report_bear200sma = run_query(TDAmeritradeDataInterface.select_sma200_bear_cross(@report_date))
  end

  def week52_highs
    @report = run_query(TDAmeritradeDataInterface.select_52week_highs(@report_date))
  end

  def ticker_list
    @report = Ticker.watching.order(id: :desc)
  end

  def hammers
    @report = run_query(TDAmeritradeDataInterface.select_hammers)
  end

  def active_stocks
    @report = run_query(TDAmeritradeDataInterface.select_active_stocks)
  end

  def candle_row
    @report_winners = run_query(TDAmeritradeDataInterface.select_4_green_candles(@report_date))
    @report_losers = run_query(TDAmeritradeDataInterface.select_4_red_candles(@report_date))

  end

  def pctgainloss
    @report_winners = run_query(TDAmeritradeDataInterface.select_10pct_gainers(@report_date))
    @report_losers = run_query(TDAmeritradeDataInterface.select_10pct_losers(@report_date))
  end

private
  def run_query(qry)
    ActiveRecord::Base.connection.execute qry
  end

  def set_report_date
    begin
      @report_date = Date.strptime(params[:report_date], '%m/%d/%Y')
    rescue
      @report_date = DailyStockPrice.most_recent_date
    end
  end
end
