#
# TODO - I don't like the way the change report is handled - will think of a better abstraction later
#
module MarketDataUtilities
  module TickerList
    class InsertLineItems
      include Verbalize::Action

      attr_reader :change_report

      input :input

      def call
        @change_report = { updated_company_names: [], tickers_added: [], tickers_dropped: [] }

        # Updating the on_nasdaq_list flag should probably be abstracted to a new class, but put it here to save time
        ticker_list_before = Ticker.where(on_nasdaq_list: true).pluck(:symbol, :company_name)
        Ticker.update_all(on_nasdaq_list: false)

        input.each do |line_item|
          existing_ticker = Ticker.find_by(symbol: line_item[:symbol])
          if existing_ticker
            update_existing_ticker(existing_ticker, line_item)
          else
            insert_new_ticker(line_item)
          end
        end

        @change_report[:tickers_dropped] = tickers_dropped(ticker_list_before)
        @change_report
      end

      private

      def insert_new_ticker(attributes)
        new_ticker_attrs = attributes.merge({scrape_data: true, on_nasdaq_list: true})
        Ticker.create!(new_ticker_attrs)
        @change_report[:tickers_added] << [attributes[:symbol], attributes[:company_name]]
      end

      def tickers_dropped(ticker_list_before)
        ticker_list_after = Ticker.where(on_nasdaq_list: true).pluck(:symbol, :company_name)
        ticker_list_before.reject do |symbol, _company_name|
          ticker_list_after.map { |after_symbol, after_company_name| after_symbol }.include?(symbol)
        end
      end

      def update_existing_ticker(ticker, new_attributes)
        if new_attributes[:company_name] != ticker.company_name
          @change_report[:updated_company_names] << {
            symbol: ticker.symbol,
            previous_company_name: ticker.company_name,
            new_company_name: new_attributes[:company_name],
            scrape_data: true,
          }
        end

        ticker.update(new_attributes.merge(on_nasdaq_list: true).reject{ |_k,v| v.nil? })
      end

    end
  end
end