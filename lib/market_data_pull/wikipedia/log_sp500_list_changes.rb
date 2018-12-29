module MarketDataPull
  module Wikipedia
    module LogSP500ListChanges
      module_function

      def call(old_list, new_list)
        (old_list - new_list).each do |symbol|
          TickerChange.create(
            action_date: Date.current,
            ticker_symbol: symbol,
            type: :sp500_index,
            old_value: true,
            new_value: false,
          )
        end

        (new_list - old_list).each do |symbol|
          TickerChange.create(
            action_date: Date.current,
            ticker_symbol: symbol,
            type: :sp500_index,
            old_value: false,
            new_value: true,
            )
        end
      end

      private

    end
  end
end