module MarketDataPull
  module Nasdaq
    module InstitutionalHoldings
      class ScrapeAll
        include Verbalize::Action

        def call
          create_html_page_container_dir

          tickers_to_scrape.each_with_index do |symbol, i|
            print "Scraping #{i+1} of #{tickers_to_scrape.size} - #{symbol}..."
            values = MarketDataPull::Nasdaq::InstitutionalHoldings::ScrapePage.(
              symbol: symbol,
                save_page_html_file: file_path_for_symbol(symbol)
            ).value
            MarketDataPull::Nasdaq::InstitutionalHoldings::PopulateNewSnapshot.(symbol: symbol, values: values)
            print "#{values[:institutional_ownership_pct]}%\n"

            sleep(Random.rand(2..16))
          end
        end

        private

        def create_html_page_container_dir
          Dir.mkdir(html_page_dir) unless Dir.exists?(html_page_dir)
        end

        def file_path_for_symbol(symbol)
          File.join(html_page_dir, "institutional-ownership-#{symbol}.html")
        end

        def html_page_dir
          @html_page_dir ||= File.join(STOCK_TREND_FINDER_DATA_DIR, 'nasdaq_scrape/institutional_ownership', Date.today.strftime('%Y%m%d'))
        end

        def tickers_to_scrape
          @tickers_to_scrape ||=
            Ticker.where(scrape_data: true).pluck(:symbol) -
              InstitutionalOwnershipSnapshot.where('scrape_date > ?', Date.today - 2).pluck(:ticker_symbol)
        end

      end
    end
  end
end