module MarketDataPull
  module TDAmeritrade
    class TDAmeritradeAPIBase

      private

      def client
        @client ||= TDAmeritradeToken.build_client_with_new_access_token
      end

      def attempts
        @attempts ||= 0
      end

      def increase_attempts
        @attempts += 1
      end

      def reset_attempts
        @attempts = 0
      end

      def handle_rate_limit_error
        puts "Rate limit error"
        sleep 31
        increase_attempts
        raise 'TDAmeritrade API error' if attempts >= 3
      end

      def with_rate_limit_safeguard(&block)
        block.call
      rescue ::TDAmeritrade::Error::RateLimitError => e
        handle_rate_limit_error && retry
      end

      def long_to_time(long)
        Time.at(long / 1000)
      end

    end
  end
end