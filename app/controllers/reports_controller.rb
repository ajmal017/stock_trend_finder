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

  # What I want on earnings report:
  # HEADING: DATE / BEFORE_OR_AFTER MARKET
  # - Ticker
  # - Name
  # - Category
  # - Last Price
  # - Average Daily Volume
  # - Float
  # - Short interest (ratio/% of float)
  def earnings
    @report = build_upcoming_earnings_report
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

  def build_upcoming_earnings_report
    @report = []
    EarningsDay
        .where("earnings_date <= ?", @report_date)
        .order(earnings_date: :desc, before_the_open: :desc)
        .last(6)
        .each do |earnings_day|
          report_group = {
              earnings_date: earnings_day.earnings_date,
              before_after: earnings_day.before_the_open? ? "Before the Open" : "After the Close",
              data: []
          }
          ticker_list = earnings_day.tickers.split(',')
          tickers = Ticker.where(symbol: ticker_list).order(:symbol)
          last_stock_prices = DailyStockPrice
                              .where(ticker_symbol: ticker_list, price_date: DailyStockPrice.most_recent_date)

          tickers.each do |ticker|
            dsp = last_stock_prices.select { |lsp| lsp.ticker_symbol==ticker.symbol }.try(:first)

            ticker_properties={}
            ticker_properties['ticker_symbol'] = ticker.symbol
            ticker_properties['company_name'] = ticker.company_name
            ticker_properties['category'] = '' # I haven't created category tags yet
            ticker_properties['last_trade'] = dsp.try(:close).try(:to_s)
            ticker_properties['average_volume'] = dsp.try(:average_volume_50day).try(:to_s)
            ticker_properties['float'] = ticker.float.to_s
            ticker_properties['short_interest'] = ''  # Not implemented yet

            report_group[:data] << ticker_properties
          end
          @report << report_group
    end
    @report
  end
end
