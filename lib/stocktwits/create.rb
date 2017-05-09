# TODO this should replace the logic in Stocktwit.sync_twits for adding new twits

module Stocktwits
  class Create
    include Verbalize::Action

    input :stocktwit_time, :message, :user_name,
          optional: [
            :symbols,
            :hashtags,
            :stocktwit_id,
            :stocktwit_url,

            :image_thumbnail_url,
            :image_large_url,
            :image_original_url
          ]

    def call
      twit = Stocktwit.create(
        stocktwit_id: stocktwit_id,
        stocktwit_time: stocktwit_time,
        stocktwit_url: stocktwit_url,
        symbol: symbols.first,
        message: message,
        image_thumb_url: image_thumbnail_url,
        image_large_url: image_large_url,
        image_original_url: image_original_url,
        hide: false,
        stocktwits_user_name: user_name
      )

      symbols.each { |s| twit.stocktwit_tickers.create(ticker_symbol: s) }
      hashtags.each { |ht| twit.stocktwit_hashtags.create(tag: ht) }

      twit
    end

    private

    def hashtags
      @hashtags || []
    end

    def symbols
      @symbols || []
    end
  end
end
