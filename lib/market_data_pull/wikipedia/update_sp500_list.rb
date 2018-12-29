module MarketDataPull
  module Wikipedia
    class UpdateSP500List
      include Verbalize::Action

      def call
        reset_existing_list

        raise 'Error downloading list' if new_index_list.size < 500

        Ticker.where(symbol: new_index_list).update_all(sp500: true)
        LogSP500ListChanges.call(@existing_list, new_index_list)
      end

      private

      def new_index_list
        @new_index_list ||= FetchSP500List.call.value
      end

      def reset_existing_list
        @existing_list = Ticker.where(sp500: true).pluck(:symbol)
        Ticker.update_all(sp500: false)
      end

    end
  end
end