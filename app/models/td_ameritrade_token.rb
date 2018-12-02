class TdAmeritradeToken < ActiveRecord::Base
  def self.get_refresh_token
    self.last.refresh_token
  end

  def self.set_refresh_token(new_token)
    self.delete_all
    self.create!(refresh_token: new_token)
  end
end
