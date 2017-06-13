require 'tdameritrade_data_interface/tdameritrade_data_interface'

class ReportsController < ApplicationController
  include Reports::Build::SQL
  before_filter :set_report_date

  def active_stocks
    @fields = [:ticker_symbol, :last_trade, :change_percent, :volume, :volume_average, :volume_ratio, :short_days_to_cover, :short_percent_of_float, :float, :float_percent_traded, :institutional_ownership_percent, :actions]
    line_items = Reports::Build::Active.call(report_date: @report_date).value
    sorted_line_items = Reports::Presenters::LineItemSort.(line_items: line_items, sort_field: sort_field, sort_direction: :desc).value

    @report = {
      title: 'Active Stocks Report',
      last_updated: sorted_line_items.size > 0 ? sorted_line_items.first[:snapshot_time].in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S') : '',
      item_count: sorted_line_items.size,
      sections: Reports::Build::Sections::Active.(report: sorted_line_items).value,
      route: :active_stocks,
    }

    render :report
  end

  def afterhours
    @fields = [:ticker_symbol, :last_trade, :change_percent, :volume, :volume_average, :volume_ratio, :short_days_to_cover, :short_percent_of_float, :float, :float_percent_traded, :institutional_ownership_percent, :actions]

    line_items = Reports::Build::AfterHours.call(report_date: @report_date).value
    sorted_line_items = Reports::Presenters::LineItemSort.(line_items: line_items, sort_field: sort_field, sort_direction: :desc).value

    @report = {
      title: 'After Hours Report',
      last_updated: sorted_line_items.size > 0 ? sorted_line_items.first[:snapshot_time].in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S') : '',
      item_count: sorted_line_items.size,
      sections: Reports::Build::Sections::AfterHours.(report: sorted_line_items).value,
      route: :afterhours,
    }

    render :report
  end

  def gaps
    @fields = [:ticker_symbol, :last_trade, :change_percent, :gap_percent, :volume, :volume_average, :volume_ratio, :short_days_to_cover, :short_percent_of_float, :float, :float_percent_traded, :institutional_ownership_percent, :actions]

    line_items = Reports::Build::Gaps.call(report_date: @report_date).value
    sorted_line_items = Reports::Presenters::LineItemSort.(line_items: line_items, sort_field: sort_field, sort_direction: :desc).value

    @report = {
      title: 'Gap Up / Gap Down Report',
      last_updated: sorted_line_items.size > 0 ? sorted_line_items.first[:snapshot_time].in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S') : '',
      item_count: sorted_line_items.size,
      sections: Reports::Build::Sections::Gaps.(report: sorted_line_items).value,
      route: :gaps,
    }

    render :report
  end

  def premarket
    @fields = [:ticker_symbol, :last_trade, :change_percent, :volume, :volume_average, :volume_ratio, :short_days_to_cover, :short_percent_of_float, :float, :float_percent_traded, :institutional_ownership_percent, :actions]

    line_items = Reports::Build::Premarket.call(report_date: @report_date).value
    sorted_line_items = Reports::Presenters::LineItemSort.(line_items: line_items, sort_field: sort_field, sort_direction: :desc).value

    @report = {
      title: 'Premarket Report',
      last_updated: sorted_line_items.size > 0 ? sorted_line_items.first[:snapshot_time].in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S') : '',
      item_count: sorted_line_items.size,
      sections: Reports::Build::Sections::Premarket.(report: sorted_line_items).value,
      route: :premarket,
    }

    render :report
  end

  def hide_symbol
    @symbol = params[:symbol]
    Ticker.find_by(symbol: @symbol).hide_from_reports(1)
  end

  def unscrape_symbol
    @symbol = params[:symbol]
    Ticker.unscrape(@symbol)
  end

  def week52_highs
    @fields = [:ticker_symbol, :last_trade, :percent_above_52_week_high, :volume, :volume_average, :volume_ratio, :short_days_to_cover, :short_percent_of_float, :float, :float_percent_traded, :institutional_ownership_percent, :actions]

    line_items = Reports::Build::FiftyTwoWeekHigh.call(report_date: @report_date).value
    sorted_line_items = Reports::Presenters::LineItemSort.(line_items: line_items, sort_field: sort_field, sort_direction: :desc).value

    @report = {
      title: '52 Week High List',
      last_updated: sorted_line_items.size > 0 ? sorted_line_items.first[:snapshot_time].in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S') : '',
      item_count: sorted_line_items.size,
      sections: Reports::Build::Sections::FiftyTwoWeekHigh.(report: sorted_line_items).value,
      route: :week52_highs,
    }

    render :report
  end

  def ticker_list
    @report = Ticker
      .watching
      .order(date_added: :desc)
      .to_a
      .map do |ar|
        {
          symbol: ar.symbol,
          company_name: ar.company_name,
          exchange: ar.exchange,
          float: ar.float.to_s,
          institutional_ownership_pct: ar.institutional_holdings_percent.to_s,
        }.stringify_keys
      end
  end

  def pctgainloss
    @report_winners = run_query(TDAmeritradeDataInterface.select_10pct_gainers(@report_date))
    @report_losers = run_query(TDAmeritradeDataInterface.select_10pct_losers(@report_date))
  end

private
  

  def run_query(qry, fields=nil)
    ReportPresenter.format(
      ActiveRecord::Base.connection.execute(qry),
      fields,
      sort_field: params[:sort_field].try(:to_sym) || :volume_ratio
    )
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

  def sort_field
    params[:sort_field].try(:to_sym) || :volume_ratio
  end
end
