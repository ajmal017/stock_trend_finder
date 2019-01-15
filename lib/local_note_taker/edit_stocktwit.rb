module LocalNoteTaker
  class EditStocktwit
    include ParseTags
    include Verbalize::Action

    attr_reader :twit

    input :stocktwit_id, :message

    def call
      twit.update(message: message)

      symbols.each { |s| twit.stocktwit_tickers.find_or_create_by(ticker_symbol: s) }

      twit.stocktwit_hashtags.destroy_all
      hashtags.each { |ht| twit.stocktwit_hashtags.create(tag: ht) }

      twit.reload
    end

    private

    def hashtags
      @hashtags ||= parse_hashtags(message)
    end

    def symbols
      @symbols ||= parse_symbols(message)
    end

    def twit
      @twit ||= Stocktwit.find(stocktwit_id)
    end
  end
end
