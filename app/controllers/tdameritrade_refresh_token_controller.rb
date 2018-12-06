class TDAmeritradeRefreshTokenController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def show
    raise RuntimeError if params['secret'] != ENV['TOS_LOCAL_SECRET']

    render json: { token: TDAmeritradeToken.get_refresh_token }
  end

  def update
    raise RuntimeError if params['secret'] != ENV['TOS_LOCAL_SECRET']
    TDAmeritradeToken.set_refresh_token(params['token'])
    render status: :ok, nothing: true
  end
end