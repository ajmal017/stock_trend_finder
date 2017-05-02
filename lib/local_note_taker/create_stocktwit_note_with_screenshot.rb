module LocalNoteTaker
  class CreateStocktwitNoteWithScreenshot
    include Verbalize::Action

    input :note

    def call
      raise "You forgot to add ticker symbol" if symbols.empty?
      outcome, result = Stocktwits::Create.call(
        stocktwit_time: Time.now,
        message: note,
        user_name: 'greenspud',
        symbols: symbols,
        hashtags: hashtags,
        image_thumbnail_url: screenshot_file_url, # decided not to use thumbnails
        image_large_url: screenshot_file_url,
        image_original_url: screenshot_file_url,
      )

      result
    end

    private

    def hashtags
      @hashtags ||= note.scan(/#\S*/)
    end

    # First characters of the note should be the ticker symbol
    def symbols
      @symbols ||= note.scan(/^[A-Z]+/)
    end

    def screenshot_file_paths
      @screenshot_file_paths ||= Screenshot.call(symbol: symbols.first).value
    end

    def screenshot_file_url
      @screenshot_file_url ||= "/local_note_taker_screenshots/full_size/#{screenshot_file_paths[:image]}"
    end

    # Decided we're not going to use thumbnails, but keeping the code here in case I change my mind
    # def thumbnail_file_url
    #   @thumbnail_file_url ||= "/local_note_taker_screenshots/thumbnails/#{screenshot_file_paths[:thumbnail]}"
    # end
  end
end