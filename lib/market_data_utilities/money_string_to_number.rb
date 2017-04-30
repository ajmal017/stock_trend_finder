module MarketDataUtilities
  module MoneyStringToNumber

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
    
  end
end