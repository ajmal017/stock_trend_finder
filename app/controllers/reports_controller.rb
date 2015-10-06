require 'tdameritrade_data_interface/tdameritrade_data_interface'

class ReportsController < ApplicationController
  before_filter :set_report_date
  before_filter :set_vix_contango_reading

  def hide_symbol
    @symbol = params[:symbol]
    Ticker.find_by(symbol: @symbol).hide_from_reports(3)
  end

  def unscrape_symbol
    @symbol = params[:symbol]
    Ticker.unscrape(@symbol)
  end

  def range
    @report = run_query(TDAmeritradeDataInterface.select_big_range(@report_date))
  end

  def ipo_list
    @report = run_query(TDAmeritradeDataInterface.select_ipo_list)
  end

  def gaps
    @report_bullgaps = run_query(TDAmeritradeDataInterface.select_bullish_gaps(@report_date))
    @report_beargaps = run_query(TDAmeritradeDataInterface.select_bearish_gaps(@report_date))
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
    @report = run_query(TDAmeritradeDataInterface.select_active_stocks(@report_date))

    @report_up   = @report.select { |r| r['pct_change'].to_f >= 0 }
    @report_down = @report.select { |r| r['pct_change'].to_f < 0  }
  end

  def candle_row
    @report_winners = run_query(TDAmeritradeDataInterface.select_4_green_candles(@report_date))
    @report_losers = run_query(TDAmeritradeDataInterface.select_4_red_candles(@report_date))

  end

  def pctgainloss
    @report_winners = run_query(TDAmeritradeDataInterface.select_10pct_gainers(@report_date))
    @report_losers = run_query(TDAmeritradeDataInterface.select_10pct_losers(@report_date))
  end

  def premarket
    @report_volume = run_query(TDAmeritradeDataInterface.select_premarket_by_volume(@report_date))
    @report_percent = run_query(TDAmeritradeDataInterface.select_premarket_by_percent(@report_date))

    @report_volume_up = @report_volume.select { |r| r['pct_change'].to_f >= 0 }
    @report_volume_down = @report_volume.select { |r| r['pct_change'].to_f < 0 }
  end

  def afterhours
    @report_volume = run_query(TDAmeritradeDataInterface.select_afterhours_by_volume(@report_date))
    @report_percent = run_query(TDAmeritradeDataInterface.select_afterhours_by_percent(@report_date))

    @report_volume_up = @report_volume.select { |r| r['pct_change'].to_f >= 0 }
    @report_volume_down = @report_volume.select { |r| r['pct_change'].to_f < 0 }
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

  def set_vix_contango_reading
    @vix = VIXFuturesHistory.last
  end
end
