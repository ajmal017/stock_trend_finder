require 'tda/watchlists/add_symbol_to_watchlist'

module TDAData
  class TDADataControllerBase < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :validate_security_token!

    private

    def validate_security_token!
      raise RuntimeError if params['secret'] != ENV['TOS_LOCAL_SECRET']
    end
  end
end