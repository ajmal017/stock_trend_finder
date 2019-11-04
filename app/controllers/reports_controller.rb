require 'tdameritrade_data_interface/tdameritrade_data_interface'

class ReportsController < ApplicationController
  include Reports::Build::SQL

  def active_stocks
    @fields = [
      :ticker_symbol,
      :last_trade,
      :change_percent,
      :volume,
      :volume_average,
      :volume_ratio,
      :short_days_to_cover,
      :short_percent_of_float,
      :float,
      :float_percent_traded,
      :dividend_yield,
      :institutional_ownership_percent,
      :index,
      :actions
    ]
    line_items = Reports::Build::Active.call(report_date: report_date).value
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
    @fields = [
      :ticker_symbol,
      :last_trade,
      :change_percent,
      :volume,
      :volume_average,
      :volume_ratio,
      :short_days_to_cover,
      :short_percent_of_float,
      :float,
      :float_percent_traded,
      :dividend_yield,
      :institutional_ownership_percent,
      :index,
      :actions
    ]

    line_items = Reports::Build::AfterHours.call(report_date: report_date).value
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
    @fields = [
      :ticker_symbol,
      :last_trade,
      :change_percent,
      :gap_percent,
      :volume,
      :volume_average,
      :volume_ratio,
      :short_days_to_cover,
      :short_percent_of_float,
      :float,
      :float_percent_traded,
      :dividend_yield,
      :institutional_ownership_percent,
      :index,
      :actions
    ]

    line_items = Reports::Build::Gaps.call(report_date: report_date).value
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
    @fields = [
      :ticker_symbol,
      :last_trade,
      :change_percent,
      :volume,
      :volume_average,
      :volume_ratio,
      :short_days_to_cover,
      :short_percent_of_float,
      :float,
      :float_percent_traded,
      :market_cap,
      :dividend_yield,
      :institutional_ownership_percent,
      :outside_52_week_range,
      :index,
      :actions
    ]

    line_items = Reports::Build::Premarket.call(report_date: report_date).value
    filtered_line_items = filter(line_items)
    sorted_line_items = Reports::Presenters::LineItemSort.(line_items: filtered_line_items, sort_field: sort_field, sort_direction: :desc).value

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
    hidden_until = Actions::HideTickerFromReports.(ticker: @symbol).value
    if hidden_until.present?
      flash[:notice] = "#{@symbol} hidden until #{hidden_until}"
    else
      flash[:notice] = "#{@symbol} unhidden"
    end
  end

  def unscrape_symbol
    @symbol = params[:symbol]
    Ticker.unscrape(@symbol)
  end

  def week52_highs
    @fields = [
      :ticker_symbol,
      :last_trade,
      :change_percent,
      :percent_above_52_week_high,
      :volume,
      :volume_average,
      :volume_ratio,
      :week_52_streak,
      :days_active,
      :float,
      :float_percent_traded,
      :dividend_yield,
      :institutional_ownership_percent,
      :market_cap,
      :index,
      :actions
    ]

    line_items = Reports::Build::FiftyTwoWeekHigh.call(report_date: report_date).value
    filtered_line_items = filter(line_items)
    sorted_line_items = Reports::Presenters::LineItemSort.(line_items: filtered_line_items, sort_field: sort_field).value

    @report = {
      title: '52 Week High List',
      last_updated: sorted_line_items.size > 0 ? sorted_line_items.first[:snapshot_time].in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S') : '',
      item_count: sorted_line_items.size,
      sections: Reports::Build::Sections::FiftyTwoWeekHigh.(report: sorted_line_items).value,
      route: :week52_highs,
      report_date: report_date,
      reviewed_date: ReportReview.report_reviewed_date(:week52_highs, report_date),
      unfiltered_item_count: line_items.size
    }

    render :report
  end

  def week52_lows
    @fields = [
      :ticker_symbol,
      :last_trade,
      :change_percent,
      :percent_below_52_week_low,
      :volume,
      :volume_average,
      :volume_ratio,
      :week_52_streak,
      :days_active,
      :float,
      :float_percent_traded,
      :market_cap,
      :dividend_yield,
      :institutional_ownership_percent,
      :index,
      :actions
    ]

    line_items = Reports::Build::FiftyTwoWeekLow.call(report_date: report_date).value
    filtered_line_items = filter(line_items)
    sorted_line_items = Reports::Presenters::LineItemSort.(line_items: filtered_line_items, sort_field: sort_field).value

    @report = {
      title: '52 Week Low List',
      last_updated: sorted_line_items.size > 0 ? sorted_line_items.first[:snapshot_time].in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S') : '',
      item_count: sorted_line_items.size,
      sections: Reports::Build::Sections::FiftyTwoWeekLow.(report: sorted_line_items).value,
      route: :week52_lows,
      unfiltered_item_count: line_items.size
    }

    render :report
  end

  def ticker_list
    line_items = Reports::Build::TickerList.call(report_date: report_date).value

    @report = {
      title: 'Master Ticker List',
      last_updated: Time.current.in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S'),
      line_items: line_items,
      item_count: line_items.size,
    }

    render :ticker_list_report
  end

  def industry
    line_items = Reports::Build::Industry.call(report_date: report_date).value

    ### INCOMPLETE - NOT READY YET ###

    #
    # @report = {
    #   title: 'Master Ticker List',
    #   last_updated: Time.current.in_time_zone("US/Eastern").strftime('%Y-%m-%d %H:%M:%S'),
    #   line_items: line_items,
    #   item_count: line_items.size,
    # }
    #
    render :industry_report
  end

  def mark_reviewed
    ReportReview.log_review(params[:report_type], params[:report_date])
  end

  def reviewed_reports
    @report = { lines: ReportReview.list_by_date(report_date) }
  end

private

  # I know biz logic shouldn't be in the controller but this is experimental. Will move to interactor later.
  def filter(items)
    return items unless params[:price] || params[:mclt] || params[:mcgt] || params[:default_filter]

    if params[:default_filter]
      @sort_field = [{field: :volume_ratio, direction: :desc}, {field: :week_52_streak, direction: :asc}]
      # @sort_field = [{field: :week_52_streak, direction: :asc}]
      return items
        .reject { |li| (li[:market_cap] || 0) < 700_000 } # market cap is in thousands
        # .reject { |li| (li[:week_52_streak] || 6).to_f > 5 }
    end

    items
      .reject { |li| params[:price] && (li[:last_trade] < params[:price].to_f) }
      .reject { |li| params[:mclt] && (li[:market_cap].nil? || (li[:market_cap] < (params[:mclt].to_f * 700_000_000))) }
      .reject { |li| params[:mcgt] && (li[:market_cap].nil? || (li[:market_cap] > (params[:mcgt].to_f * 700_000_000))) }
  end

  def report_date
    begin
      @report_date ||=
        if params[:report_date] =~ /\d{2}\/\d{2}\/\d{4}/
          Date.strptime(params[:report_date], '%m/%d/%Y')
        else
          Date.strptime(params[:report_date], '%Y%m%d')
        end
    rescue
      @report_date ||= DailyStockPrice.most_recent_date
    end
  end

  def run_query(qry, fields=nil)
    ReportPresenter.format(
      ActiveRecord::Base.connection.execute(qry),
      fields,
      sort_field: params[:sort_field].try(:to_sym) || :volume_ratio
    )
  end

  def set_vix_contango_reading
    @vix = VIXFuturesHistory.last
  end

  def sort_field
    @sort_field ||= params[:sort_field].try(:to_sym) || :volume_ratio
  end
end
