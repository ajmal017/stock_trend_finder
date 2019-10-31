module ReportHelper
  RJUST_FIELDS=[
    :last_trade,
    :change_percent,
    :percent_above_52_week_high,
    :gap_percent,
    :float,
    :float_percent_traded,
    :market_cap,
    :dividend_yield,
    :institutional_ownership_percent,
    :volume,
    :volume_ratio,
    :volume_average,
    :short_days_to_cover,
    :short_percent_of_float
  ]

  def report_date_form(page, current_report_date)
    s = form_tag "/reports/#{page}", method: :get, authenticity_token: false do
      b = text_field_tag :report_date, current_report_date.strftime('%m/%d/%Y')
      b << submit_tag("Go")
      b
    end
    s.html_safe
  end

  def set_vix_contango_style(contango_percent)
    "background-color: red" if contango_percent < 1
  end

  # TODO move this method into the presenter
  def set_css_class(report, field)
    css_class = "monospaced "

    if report[:gray_symbol]
      css_class << "gray "
    else
      unless field == :index
        if report[:change_percent].to_f > 0
          css_class << "green "
        elsif report[:change_percent].to_f < 0
          css_class << "red "
        end

        if report[:gap_pct].to_f > 0
          css_class << "green "
        elsif report[:gap_pct].to_f < 0
          css_class << "red "
        end

        if report[:percent_above_52_week_high].present?
          css_class << "green "
        end

        if report[:percent_below_52_week_low].present?
          css_class << "red "
        end
      end
    end

    css_class << "rjust " if RJUST_FIELDS.include?(field)

    case field
      when :index
        if report[:sp500]
          css_class << 'orange-text'
        end
      when :percent_above_52_week_high
        if report[:percent_above_52_week_high].to_f > 5.0
          css_class << "darkgreen-bg  "
        end

        if report[:percent_above_52_week_high].to_f.abs > 7.5
          css_class << "bold "
        end

      when :change_percent
        if report[:change_percent].to_f < -7.5
          css_class << "darkred-bg  "
        elsif report[:change_percent].to_f > 7.5
          css_class << "darkgreen-bg  "
        end

        if report[:change_percent].to_f.abs > 10
          css_class << "bold "
        end
      when :gap_percent
        if report[:gap_pct].to_f < -7.5
          css_class << "darkred-bg  "
        elsif report[:gap_pct].to_f > 7.5
          css_class << "darkgreen-bg  "
        end

        if report[:gap_pct].to_f.abs > 10
          css_class << "bold "
        end
      when :float
        # Format how it is displayed into millions from thousands of shares
        # report[:float] = '%.0f' % (report[:float].to_f / 1000) if report[:float].present?

        # Have a different designator for low float stock
        # if (report[:float].to_f < 15 && (report[:float].to_f) > 0)
        #   css_class << 'gold-bg '
        # end
      when :float_percent_traded
        if report[:float_percent_traded].to_f > 75
          css_class << 'gold-bg '
        end

      when :volume_ratio then css_class << "yellow-bg " if (report[:volume_ratio].to_f > 3)
      when :range then css_class << "yellow-bg " if (report[:range].to_f > 7)
      when :unscrape then css_class << "clickable "

    end

    css_class.strip
  end

  def symbol_icon(symbol)
    image = $ticker_icon_categories[symbol]
    if image
      image_tag(asset_path(image), class: 'report-stock-icon')
    else
      ''
    end
  end

  def ticker_symbol(line_item)
    outside_52_wk_marker = line_item[:outside_52_week_range] ? content_tag(:span, " *", style: "color: orange") : ''

    link_to(
      "#{line_item[:ticker_symbol]}",
      "https://old.nasdaq.com/symbol/#{line_item[:ticker_symbol].downcase}",
      target: '_blank'
    ) + outside_52_wk_marker + symbol_icon(line_item[:ticker_symbol])
  end
end
