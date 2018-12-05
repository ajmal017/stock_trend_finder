class TDAmeritradeToken < ActiveRecord::Base
  def self.build_client
    TDAmeritrade::Client.new(
      client_id: ENV.fetch('TOS_CLIENT_ID'),
      redirect_uri: ENV.fetch('TOS_REDIRECT_URI'),
      refresh_token: TDAmeritradeToken.get_refresh_token
    )
  end

  def self.get_refresh_token
    self.last.refresh_token
  end

  def self.set_refresh_token(new_token)
    self.delete_all
    self.create!(refresh_token: new_token)
  end
end
