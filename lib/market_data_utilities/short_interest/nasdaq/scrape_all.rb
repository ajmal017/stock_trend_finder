module MarketDataUtilities
  module ShortInterest
    module Nasdaq
      class ScrapeAll
        include Verbalize::Action

        def call
          create_html_page_container_dir

          tickers_to_scrape.each_with_index do |symbol, i|
            puts "Scraping #{i+1} of #{tickers_to_scrape.size} - #{symbol}..."
            values = MarketDataUtilities::ShortInterest::Nasdaq::ScrapePage.(
              symbol: symbol,
              save_page_html_file: file_path_for_symbol(symbol)
            ).value
            MarketDataUtilities::ShortInterest::Nasdaq::PopulateShortInterestHistory.(symbol: symbol, values: values)

            sleep(Random.rand(1..8))
          end
        end

        private

        def create_html_page_container_dir
          Dir.mkdir(html_page_dir) unless Dir.exists?(html_page_dir)
        end

        def file_path_for_symbol(symbol)
          File.join(html_page_dir, "short-interest-#{symbol}.html")
        end

        def html_page_dir
          @html_page_dir ||= File.join(STOCK_TREND_FINDER_DATA_DIR, 'nasdaq_scrape/short_interest', Date.today.strftime('%Y%m%d'))
        end

        def tickers_to_scrape
          @tickers_to_scrape ||=
            Ticker.watching.pluck(:symbol)
        end

      end
    end
  end
end