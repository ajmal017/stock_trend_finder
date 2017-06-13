# frozen_string_literal: true

class ReportPresenter

  DEFAULT_FIELDS=[
    :ticker_symbol,
    :last_trade,
    :change_percent,
    :gap_percent,
    :percent_above_52_week_high,
    :volume,
    :average_volume,
    :volume_average,
    :volume_ratio,
    :short_days_to_cover,
    :short_percent_of_float,
    :float,
    :float_percent_traded,
    :institutional_ownership_percent,
    :actions
  ]


  def self.format(sql_result, fields_filter=DEFAULT_FIELDS, sort_field: :volume_ratio, sort_direction: :desc)
    new_report = []
    sql_result.each do |row|
      new_report << {
        snapshot_time: row[:snapshot_time],
        updated_at: row[:updated_at],
        gray_symbol: row[:gray_symbol]=='t',

        ticker_symbol: row[:ticker_symbol],
        company_name: row[:company_name],
        last_trade: display_number(row[:last_trade], 2),
        high: display_number(row[:high], 2),
        gap_percent: display_number(row[:gap_percent], 1),
        percent_above_52_week_high: display_number(row[:percent_above_52_week_high], 1),
        change_percent: display_number(row[:change_percent], 1),
        volume: display_number(row[:volume], 0),
        volume_average: display_number(row[:volume_average], 0),
        volume_ratio: display_number(row[:volume_ratio], 1),
        short_days_to_cover: display_number(row[:short_days_to_cover], 1),
        short_percent_of_float: display_percent(row[:short_percent_of_float], 0),
        institutional_ownership_percent: display_percent(row[:institutional_ownership_percent], 0),
        float: display_number(row[:float], 0),
        float_percent_traded: display_percent(row[:float_percent_traded], 0)
      }.slice(*(fields_filter + [:snapshot_time, :updated_at, :gray_symbol]))
    end

    # new_report.sort! { |a,b| sort_direction==:desc ? b[sort_field].to_f<=>a[sort_field].to_f : a[sort_field].to_f<=>b[sort_field].to_f }
    new_report
  end

  # everything below should be private but I haven't made the switch entirely yet

  def self.display_number(value, round=1)
    return unless (f = value.try(:to_f)).present?

    "%.#{round}f" % f
  end

  def self.display_percent(value, round=2)
    display_number(value, round).try(:+, '%')
  end

  def self.display_short(days_to_cover, float_pct)
    if days_to_cover && float_pct
      display_number(days_to_cover).rjust(5) + " | " + ("%.1f" % float_pct).rjust(3).gsub(' ', '&nbsp;') + "%"
    else
      ""
    end
  end

end