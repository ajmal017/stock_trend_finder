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
        image_thumbnail_url: thumbnail_file_url,
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

    def screenshot_file_paths
      @screenshot_file_paths ||= Screenshot.call(symbol: parse_symbols.first).value
    end

    def screenshot_file_url
      @screenshot_file_url ||= "/local_note_taker_screenshots/full_size/#{screenshot_file_paths[:image]}"
    end

    def thumbnail_file_url
      @thumbnail_file_url ||= "/local_note_taker_screenshots/thumbnails/#{screenshot_file_paths[:thumbnail]}"
    end
  end
end