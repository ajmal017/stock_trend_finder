module Twitter
  class CreateTweet
    include Verbalize::Action

    input :tweet

    def call
      posted_tweet
    end

    private

    def base_images_dir
      Rails.root.join('public/')
    end

    def client
      @client = Twitter::REST::Client.new do |c|
        c.consumer_key=ENV['TWITTER_CONSUMER_API_KEY']
        c.consumer_secret=ENV['TWITTER_SECRET_API_KEY']
        c.access_token=ENV['TWITTER_ACCESS_TOKEN']
        c.access_token_secret=ENV['TWITTER_ACCESS_SECRET']
      end
    end

    def posted_tweet
      client.update_with_media(tweet.message, File.new(File.join(base_images_dir, tweet.local_image_url)))
    end
  end
end