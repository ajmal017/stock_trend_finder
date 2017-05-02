module LocalNoteTaker
  class CreateStocktwitNoteWithScreenshot
    include Verbalize::Action

    input :note

    def call
      Stocktwits::Create.call(
        stocktwit_time: Time.now,
        message: note,
        user_name: 'greenspud',
        symbols: parse_symbols,
        hashtags: parse_hashtags,
        image_thumbnail_url: screenshot_file_url,
        image_large_url: screenshot_file_url,
        image_original_url: screenshot_file_url,
      )
    end

    private

    def parse_hashtags
      @parse_hashtags ||= note.scan(/#\S*/)
    end

    # First characters of the note should be the ticker symbol
    def parse_symbols
      @parse_symbols ||= note.scan(/^[A-Z]+/)
    end

    def screenshot_file_path
      @screenshot_file_path ||= Screenshot.call(symbol: parse_symbols.first).value
    end

    def screenshot_file_url
      @screenshot_file_url ||= "file://#{screenshot_file_path}"
    end

  end
end