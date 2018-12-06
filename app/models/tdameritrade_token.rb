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

  def self.get_refresh_token_from_server
    params = {
      "secret": ENV['TOS_LOCAL_SECRET'],
    }

    uri = URI::join(ENV['TOS_LOCAL_SERVER'], '/tdameritrade_token')
    request = Net::HTTP::Get.new(uri.path)
    request.set_form_data(params)
    response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
    JSON.parse(response.body)['token']
  end

  def self.set_refresh_token_on_server(token)
    params = {
      "secret": ENV['TOS_LOCAL_SECRET'],
      "token": token,
    }

    uri = URI::join(ENV['TOS_LOCAL_SERVER'], '/tdameritrade_token')
    request = Net::HTTP::Put.new(uri.path)
    request.set_form_data(params)
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
  end
end
