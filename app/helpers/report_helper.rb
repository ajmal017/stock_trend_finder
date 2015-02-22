module ReportHelper
  def report_date_form(page)
    s = form_tag "/reports/#{page}", method: :get, authenticity_token: false do
      b = text_field_tag :report_date, @report_date.strftime('%m/%d/%Y')
      b << submit_tag("Go")
      b
    end
    s.html_safe
  end

  def set_css_class(report, field)
    css_class = ""
    if report['pct_change'].to_f > 0
      css_class << "green "
    elsif report['pct_change'].to_f < 0
      css_class << "red "
    end

    if report['gap_pct'].to_f > 0
      css_class << "green "
    elsif report['gap_pct'].to_f < 0
      css_class << "red "
    end


    case field
      when :pct_change
        if report['pct_change'].to_f < -7.5
          css_class << "darkred-bg  "
        elsif report['pct_change'].to_f > 7.5
          css_class << "darkgreen-bg  "
        end

        if report['pct_change'].to_f.abs > 10
          css_class << "bold "
        end
      when :gap_percent
        if report['gap_pct'].to_f < -7.5
          css_class << "darkred-bg  "
        elsif report['gap_pct'].to_f > 7.5
          css_class << "darkgreen-bg  "
        end

        if report['gap_pct'].to_f.abs > 10
          css_class << "bold "
        end
      when :float then
        if (report['float'.to_f < 15] && (report['float'].to_f) > 0)
          css_class << 'darkred-bg '
        elsif (report['float'].to_f < 100) && (report['float'].to_f > 0)
          css_class << "gold-bg "
        end
      when :volume_ratio then css_class << "yellow-bg " if (report['volume_ratio'].to_f > 3)
      when :range then css_class << "yellow-bg " if (report['range'].to_f > 7)

    end

    css_class.strip
  end
end
