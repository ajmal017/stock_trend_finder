# frozen_string_literal: true

class ReportPresenter

  DEFAULT_FIELDS=[
    :ticker_symbol,
    :last_trade,
    :pct_change,
    :volume,
    :average_volume,
    :volume_ratio,
    :short_ratio,
    :float,
    :float_pct,
    :actions
  ]


  def self.format(sql_result, fields_filter=DEFAULT_FIELDS)
    new_report = []
    sql_result.each do |row|
      new_report << {
        snapshot_time: row['snapshot_time'],
        updated_at: row['updated_at'],
        gray_symbol: row['gray_symbol']=='t',

        ticker_symbol: row['ticker_symbol'],
        company_name: row['company_name'],
        last_trade: display_number(row['last_trade'], 2),
        high: display_number(row['high'], 2),
        gap_percent: display_number(row['gap_pct'], 1),
        pct_above_52: display_number(row['pct_above_52_week'], 1),
        pct_change: display_number(row['pct_change'], 1),
        volume: display_number(row['volume'], 0),
        average_volume: display_number(row['average_volume'], 0),
        volume_ratio: display_number(row['volume_ratio'], 1),
        short_ratio: display_short(row['short_ratio'], row['short_pct_float']),
        institutional_ownership_percent: display_percent(row['institutional_ownership_percent'], 0),
        float: row['float'],
        float_pct: (row['volume'].to_f > 0 && row['float'].to_f > 0) ? display_percent(row['volume'].to_f / (row['float'].to_f) * 100) : ''
      }.slice(*(fields_filter + [:snapshot_time, :updated_at, :gray_symbol]))
    end
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
      days_to_cover.rjust(5) + " | " + ("%.1f" % float_pct).rjust(3).gsub(' ', '&nbsp;') + "%"
    else
      ""
    end
  end

end