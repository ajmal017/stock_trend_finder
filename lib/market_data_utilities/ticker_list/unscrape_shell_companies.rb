module MarketDataUtilities
  module TickerList
    class UnscrapeShellCompanies
      include Verbalize::Action

      def call
        Ticker.shell_companies.map { |symbol, _company_name| Ticker.unscrape(symbol) }
      end

    end
  end
end