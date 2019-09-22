module LocalNoteTaker
  class CreateStocktwitNoteWithScreenshot
    include ParseTags
    include Verbalize::Action

    input :note, optional: [:stocktwit_time, :screen_count]

    def call
      raise "You forgot to add ticker symbol" if symbols.empty?
      outcome, result = Stocktwits::Create.call(
        stocktwit_time: @stocktwit_time || Time.now,
        message: note,
        user_name: 'greenspud',
        symbols: symbols,
        hashtags: hashtags,
        image_thumbnail_url: thumbnail_file_url, # decided not to use thumbnails
        image_large_url: screenshot_file_url,
        image_original_url: screenshot_file_url,
        image_cropped_url: screenshot_cropped_file_url
      )

      symbols.each do |symbol|
        AddSymbolToTosWatchlist.(symbol: symbol)
      end

      result
    end

    private

    def hashtags
      @hashtags ||= parse_hashtags(note)
    end

    # First characters of the note should be the ticker symbol
    def symbols
      @symbols ||= parse_symbols(note)
    end

    def screenshot_file_paths
      sleep 4 if @screen_count == 1
      @screenshot_file_paths ||= Screenshot.call(symbol: symbols.first, screen_count: @screen_count).value
    end

    def screenshot_file_url
      @screenshot_file_url ||= "/local_note_taker_screenshots/full_size/#{screenshot_file_paths[:image]}"
    end

    def screenshot_cropped_file_url
      @screenshot_cropped_url ||= "/local_note_taker_screenshots/cropped/#{screenshot_file_paths[:cropped]}"
    end

    def thumbnail_file_url
      @thumbnail_file_url ||= "/local_note_taker_screenshots/thumbnails/#{screenshot_file_paths[:thumbnail]}"
    end
  end
end