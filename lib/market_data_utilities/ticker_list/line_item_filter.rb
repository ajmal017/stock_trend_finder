require 'market_data_utilities/money_string_to_number'

module MarketDataUtilities
  module TickerList
    class LineItemFilter
      extend MarketDataUtilities::MoneyStringToNumber

      class << self
        def convert_market_caps(line_items)
          line_items.each do |line_item|
            if line_item[:market_cap] == 'n/a'
              line_item.delete(:market_cap)
            else
              line_item[:market_cap] = money_string_to_number(line_item[:market_cap])
            end
          end
        end

        def remove_invalid_tickers(line_items)
          line_items.select { |li| li[:symbol] =~ /\A[A-Z]+\z/  }
        end

        def remove_missing_industry_tag(line_items)
          line_items.select { |li| li[:sector] != 'n/a' && li[:industry] != 'n/a' }
        end

        def run_all(line_items)
          result = self.convert_market_caps(line_items)
          result = self.remove_invalid_tickers(result)
          self.remove_missing_industry_tag(result)
        end
      end
    end
  end
end