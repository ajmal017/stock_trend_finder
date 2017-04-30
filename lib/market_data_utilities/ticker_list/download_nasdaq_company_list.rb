#
# Skipping the writing of tests for this because I don't want to actually download the files from Nasdaq. This process
# will be running monthly so I'll know right away if the lists disappear or change location.
#
module MarketDataUtilities
  module TickerList
    class DownloadNasdaqCompanyList
      include Verbalize::Action

      # From http://www.nasdaq.com/screening/company-list.aspx
      FILE_URLS=[
        ['nasdaq', 'http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download'],
        ['nyse', 'http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download'],
        ['amex', 'http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download'],
      ]

      def call
        FILE_URLS.each do |exchange, url|
          `#{command(url, destination_name(exchange))}`
        end
      end

      private

      def command(url, destination_file)
        "wget -O #{destination_file} \"#{url}\""
      end

      def destination_name(exchange)
        File.join(
          STOCK_TREND_FINDER_DATA_DIR,
          'nasdaq_company_lists',
          "companylist-#{Date.today.strftime('%Y%m%d')}-#{exchange}.csv"
        )
      end

    end
  end
end