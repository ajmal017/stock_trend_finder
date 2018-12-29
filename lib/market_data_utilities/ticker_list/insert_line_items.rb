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

        # Stop scraping defunct symbols
        Ticker.where(on_nasdaq_list: false, scrape_data: true).update_all(scrape_data: false, unscrape_date: Date.current)

        @change_report[:tickers_dropped] = tickers_dropped(ticker_list_before)
        save_change_history
        @change_report
      end

      private

      def insert_new_ticker(attributes)
        new_ticker_attrs = attributes.merge(scrape_data: true, on_nasdaq_list: true, date_added: Date.today)
        Ticker.create!(new_ticker_attrs)
        @change_report[:tickers_added] << [attributes[:symbol], attributes[:company_name]]
      end

      def tickers_dropped(ticker_list_before)
        ticker_list_after = Ticker.where(on_nasdaq_list: true).pluck(:symbol, :company_name)
        ticker_list_before.reject do |symbol, _company_name|
          ticker_list_after.map { |after_symbol, _after_company_name| after_symbol }.include?(symbol)
        end
      end

      def save_change_history
        @change_report[:tickers_added].each do |ta|
          TickerChange.create(
            ticker_symbol: ta[0],
            action_date: Date.current,
            type: 'add'
          )
        end
        @change_report[:updated_company_names].each do |ta|
          TickerChange.create(
            ticker_symbol: ta[:symbol],
            action_date: Date.current,
            type: 'change_name',
            old_value: ta[:previous_company_name],
            new_value: ta[:new_company_name]
          )
        end
        @change_report[:tickers_dropped].each do |ta|
          TickerChange.create(
            ticker_symbol: ta[0],
            action_date: Date.current,
            type: 'remove'
          )
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

        # Only set it to scrapable from unscrapable if the company name changed (i.e. ticker gets recycled under new company)
        scrape_data = ticker.scrape_data? || (new_attributes[:company_name] != ticker.company_name)

        ticker.update(
          new_attributes.merge(
            on_nasdaq_list: true,
            scrape_data: scrape_data,
            date_added: (scrape_data && !ticker.scrape_data? ? Date.today : ticker.date_added)
        ).reject{ |_k,v| v.nil? })
      end

    end
  end
end