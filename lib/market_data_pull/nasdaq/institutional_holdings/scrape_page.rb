module MarketDataPull
  module Nasdaq
    module InstitutionalHoldings
      class ScrapePage
        include Verbalize::Action

        input :symbol, optional: [:save_page_html_file]

        def call
          save_page_html if save_page_html_file.present?

          ParsePageData.(page_html: page_contents).value
        end

        private

        def header
          header = HTTPX::Headers.new
          header.add_header('User-Agent', DEFAULT_SCRAPER_AGENT)
          header
        end

        def page_contents
          @page_contents ||=
            # Can't use net/http because it doesn't support HTTP 2.0, which is what Nasdaq server sends back (only does HTTP 1.1)
            HTTPX.request(:get, page_uri, headers: header).body.to_s
        rescue Exception =>e
          raise e
        end

        def page_uri
          @page_uri ||= "https://www.nasdaq.com/symbol/#{symbol.downcase}/institutional-holdings"
        end

        def save_page_html
          File.open(save_page_html_file, 'w') { |f| f.write(page_contents) }
        end
      end
    end
  end
end