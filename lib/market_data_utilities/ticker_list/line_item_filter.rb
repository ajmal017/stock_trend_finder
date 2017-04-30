require 'market_data_utilities/money_string_to_number'

module MarketDataUtilities
  module TickerList
    module LineItemFilter
      extend MarketDataUtilities::MoneyStringToNumber
      extend self

      def convert_market_caps(line_items)
        line_items.each do |line_item|
          if line_item[:market_cap] == 'n/a'
            line_item.delete(:market_cap)
          else
            line_item[:market_cap] = money_string_to_number(line_item[:market_cap])
          end
        end
      end
    end
  end
end