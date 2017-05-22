module MarketDataUtilities
  module ShortInterest
    module Nasdaq
      class ScrapeAll
        include Verbalize::Action

        input optional: [:as_of_date]

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

        def as_of_date
          @as_of_date ||= Date.today
        end

        def create_html_page_container_dir
          Dir.mkdir(html_page_dir) unless Dir.exists?(html_page_dir)
        end

        def file_path_for_symbol(symbol)
          File.join(html_page_dir, "short-interest-#{symbol}.html")
        end

        def html_page_dir
          @html_page_dir ||= File.join(STOCK_TREND_FINDER_DATA_DIR, 'nasdaq_scrape/short_interest', as_of_date.strftime('%Y%m%d'))
        end

        def processed_tickers
          files = []
          d = Dir.new(File.join(STOCK_TREND_FINDER_DATA_DIR, 'nasdaq_scrape/short_interest/', as_of_date.strftime('%Y%m%d')))
          d.each { |x| files << x }

          files.flat_map do |filename|
            filename.scan(/short-interest-([A-Z]+)\.html/).flatten
          end.compact.uniq
        end

        def tickers_to_scrape
          @tickers_to_scrape ||= Ticker.watching.pluck(:symbol) - processed_tickers
        end

      end
    end
  end
end