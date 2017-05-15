require 'market_data_utilities/money_string_to_number'

module MarketDataUtilities
  module TickerList
    class LineItemFilter
      extend MarketDataUtilities::MoneyStringToNumber

      class << self
        COMPANY_NAME_BLACKLIST_TEXT=[
          /\bFund\b/,
          /(Anywhere|Bond|Credit|Dividend|Income|Investment|Municipal|Opportunity|Quality|Tax-Exempt|Term|Value) Trust\b/,
          /(BlackRock|Eaton Vance|Franklin|John Hancock|KKR|Pioneer|Putnam) .+ Trust$/,
          /(Gabelli|Invesco|Royce|Sprott) .+ Trust/,
          /\bETF\b/,
          /\bIndex$/,
          /\b(iShares|PowerShares|ProShares|Proshares|Western Asset\/Claymore|WisdomTree Barclays)\b/,
          /\bPortfolio$/
        ]

        def convert_market_caps(line_items)
          line_items.each do |line_item|
            if line_item[:market_cap] == 'n/a'
              line_item.delete(:market_cap)
            else
              line_item[:market_cap] = money_string_to_number(line_item[:market_cap])
            end
          end
        end

        def remove_by_company_name_blacklist(line_items)
          line_items.reject { |li| COMPANY_NAME_BLACKLIST_TEXT.any? { |bl| li[:company_name] =~ bl } }
        end

        def remove_invalid_tickers(line_items)
          line_items.select { |li| li[:symbol] =~ /\A[A-Z]+\z/  }
        end

        # def remove_missing_industry_tag(line_items)
        #   line_items.select { |li| li[:sector] != 'n/a' && li[:industry] != 'n/a' }
        # end

        def remove_shell_companies(line_items)
          # line_items.reject { |li| li[:symbol] =~ /[A-Z]{4}(W|U|X)/ }
          line_items.reject { |li| li[:symbol].size > 4 }
        end

        def run_all(line_items)
          result = self.convert_market_caps(line_items)
          result = self.remove_invalid_tickers(result)
          result = self.remove_shell_companies(result)
          result = self.remove_by_company_name_blacklist(result)
          # self.remove_missing_industry_tag(result)
        end
      end
    end
  end
end