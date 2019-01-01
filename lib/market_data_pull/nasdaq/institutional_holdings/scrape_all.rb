module MarketDataPull
  module Nasdaq
    module InstitutionalHoldings
      class ScrapeAll
        include Verbalize::Action

        ADDITIONAL_TICKERS = %w(SPY)

        def call
          create_html_page_container_dir

          tickers_to_scrape.each_with_index do |symbol, i|
            print "Scraping #{i+1} of #{tickers_to_scrape.size} - #{symbol}..."
            values = MarketDataPull::Nasdaq::InstitutionalHoldings::ScrapePage.(
              symbol: symbol,
                save_page_html_file: file_path_for_symbol(symbol)
            ).value
            MarketDataPull::Nasdaq::InstitutionalHoldings::PopulateNewSnapshot.(
              symbol: symbol,
              values: values,
              scrape_filename: File.join(html_page_dir, scrape_filename(symbol))
            )
            print "#{values[:institutional_ownership_pct]}%\n"

            sleep(Random.rand(2..16))
          end

          MarketDataUtilities::InstitutionalHoldings::BuildSP500Snapshot.call(date: Date.current)
        end

        private

        def create_html_page_container_dir
          Dir.mkdir(full_html_page_dir) unless Dir.exists?(full_html_page_dir)
        end

        def file_path_for_symbol(symbol)
          File.join(full_html_page_dir, scrape_filename(symbol))
        end

        def full_html_page_dir
          File.join(STOCK_TREND_FINDER_DATA_DIR, html_page_dir)
        end

        def html_page_dir
          @html_page_dir ||= File.join('nasdaq_scrape/institutional_holdings', Date.today.strftime('%Y%m%d'))
        end

        def scrape_filename(symbol)
          "institutional-holdings-#{symbol}.html"
        end

        def tickers_to_scrape
          @tickers_to_scrape ||=
            Ticker.where(scrape_data: true).pluck(:symbol) + ADDITIONAL_TICKERS -
              InstitutionalOwnershipSnapshot.where('scrape_date > ?', Date.today - 2).pluck(:ticker_symbol)
        end

      end
    end
  end
end