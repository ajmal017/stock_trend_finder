module MarketDataUtilities
  module MoneyAsString
    module_function

    def divide_by_thousand(value, times=1)
      return 0 if value == 0 || value.nil?
      value.to_f / (times * 1_000)
    end

    def human_readable(number, precision=2, as: nil)
      f = number.try(:to_f)
      return 'NaN' if f.nil?

      if f >= 1000000000000 || as == :trillions
        "#{(f / 1000000000000).round(precision)} T"
      elsif f >= 1000000000 || as == :billions
        "#{(f / 1000000000).round(precision)} B"
      elsif f >= 1000000 || as == :millions
        "#{(f / 1000000).round(precision)} M"
      elsif f >= 1000 || as == :thousands
        "#{(f / 1000).round(precision)} K"
      else
        f.round(2).to_s
      end
    end

    def money_string_to_number(money_value)
      values = money_value.scan /\$(\d+\.*\d*)(M|B)/
      return nil if values.empty?

      amount, qualifier = values.first

      case qualifier
        when 'M'
          return amount.to_f * 1000000
        when 'B'
          return amount.to_f * 1000000000
        else
          raise "Unknown money qualifier '#{qualifier}' for the money value #{money_value}"
      end
    end

    def multiply_by_thousand(value, times=1)
      return 0 if value.nil?
      value.to_f * 1_000 * times
    end

  end
end