module MarketDataUtilities
  module Indices
    class UpdateSP500List
      include Verbalize::Action

      def call
        reset_existing_list

        raise 'Error downloading list' if index_list.size < 500

        Ticker.where(symbol: index_list).update_all(sp500: true)
      end

      private

      def index_list
        @index_list ||= FetchSP500List.call.value
      end

      def reset_existing_list
        Ticker.update_all(sp500: false)
      end

    end
  end
end