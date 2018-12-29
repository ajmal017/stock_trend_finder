module MarketDataPull
  module Wikipedia
    class FetchSP500List
      include Verbalize::Action

      LIST_URL='https://en.wikipedia.org/wiki/List_of_S%26P_500_companies'

      def call
        components
      end

      private

      def components
        component_table.css('tr').map do |tr|
          tr.css('td').first.try(:text).try(:gsub, '.', '/')
        end.compact
      end

      def component_table
        @component_table ||= noko.css('table').select do |t|
          t.css('th').first.text =~ /symbol/i
        end.first
      end

      def html
        @html ||= Net::HTTP.get(URI.parse('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies'))
      end

      def noko
        @noko ||= Nokogiri.parse(html)
      end

    end
  end
end