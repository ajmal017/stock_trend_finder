class TDAmeritradeToken < ActiveRecord::Base
  class << self
    def build_client
      TDAmeritrade::Client.new(
        client_id: ENV.fetch('TOS_CLIENT_ID'),
        redirect_uri: ENV.fetch('TOS_REDIRECT_URI'),
        refresh_token: TDAmeritradeToken.get_refresh_token
      )
    end

    def build_client_with_new_access_token
      client = self.build_client
      self.get_new_access_token(client)
      self.set_refresh_token(client.refresh_token)
      client
    end

    def get_new_access_token(client)
      client.get_new_access_token
      self.set_refresh_token(client.access_token)
      client
    end

    def get_refresh_token
      self.last.refresh_token
    end

    def set_refresh_token(new_token)
      self.delete_all
      self.create!(refresh_token: new_token)
    end

  end
end
