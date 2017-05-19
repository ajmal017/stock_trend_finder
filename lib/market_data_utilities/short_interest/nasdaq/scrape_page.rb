module MarketDataUtilities
  module ShortInterest
    module Nasdaq
      class ScrapePage
        include Verbalize::Action

        input :symbol, optional: [:save_page_html_file]

        def call
          save_page_html if save_page_html_file.present?

          ParsePageData.(page_html: page_contents.body).value
        end

        private

        # DRY - make a GetWebpage interactor class
        def page_contents
          @page_contents ||=
            Net::HTTP.start(
              page_uri.host,
              page_uri.port,
            ) do |http|
              request = Net::HTTP::Get.new(page_uri, 'User-Agent' => DEFAULT_SCRAPER_AGENT)
              http.request(request)
            end
        rescue Exception =>e
          raise e
        end

        def page_uri
          @page_uri ||= URI.parse("http://www.nasdaq.com/symbol/#{symbol.downcase}/short-interest")
        end

        def save_page_html
          File.open(save_page_html_file, 'w') do |f|
            f.write(page_contents.body.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?'))
          end
        end

      end
    end
  end
end