module Twitter
  class BuildClient
    def self.call
      Twitter::REST::Client.new do |c|
        c.consumer_key=ENV['TWITTER_CONSUMER_API_KEY']
        c.consumer_secret=ENV['TWITTER_SECRET_API_KEY']
        c.access_token=ENV['TWITTER_ACCESS_TOKEN']
        c.access_token_secret=ENV['TWITTER_ACCESS_SECRET']
      end
    end
  end
end