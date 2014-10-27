module ReportHelper
  def set_css_class(report, field)
    css_class = ""
    if report['pct_change'].to_f > 0
      css_class << "green "
    elsif report['pct_change'].to_f < 0
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
      when :float then css_class << "gold-bg " if (report['float'].to_f < 100) && (report['float'].to_f > 0)
      when :volume_ratio then css_class << "yellow-bg " if (report['volume_ratio'].to_f > 3)

    end

    css_class.strip
  end
end
