module TDA
  module OAuthAPICall
    module_function

    def rate_limit_api_requests(&block)
      block.call
    rescue TDAmeritrade::Error::RateLimitError => e
      sleep 31
      attempts = attempts + 1
      raise e if attempts >= 3
      retry
    end

    def perform_api_request(&block)
      client = TDAmeritradeToken.build_client
      client.get_new_access_token
      TDAmeritradeToken.set_refresh_token(client.refresh_token)

      block.call(client)
    end
  end
end