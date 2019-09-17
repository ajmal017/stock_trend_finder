#
# Skipping the writing of tests for this because I don't want to actually download the files from Nasdaq. This process
# will be running monthly so I'll know right away if the lists disappear or change location.
#
module MarketDataUtilities
  module TickerList
    class DownloadNasdaqCompanyList
      include Verbalize::Action

      # From http://old.nasdaq.com/screening/company-list.aspx
      FILE_URLS=[
        ['nasdaq', 'https://old.nasdaq.com/screening/companies-by-industry.aspx?letter=0&exchange=NASDAQ&render=download'],
        ['nyse', 'https://old.nasdaq.com/screening/companies-by-industry.aspx?letter=0&exchange=NYSE&render=download'],
        ['amex', 'https://old.nasdaq.com/screening/companies-by-industry.aspx?letter=0&exchange=AMEX&render=download'],
      ]

      def call
        FILE_URLS.each do |exchange, url|
          `#{command(url, destination_name(exchange))}`
        end
      end

      private

      def command(url, destination_file)
        # In a production environment, would be a good idea to download to a temporary folder then save to S3
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