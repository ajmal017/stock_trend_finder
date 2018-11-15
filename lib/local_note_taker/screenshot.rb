module LocalNoteTaker
  class Screenshot
    include Verbalize::Action

    input optional: [:symbol]

    def call
      `#{command_screencapture}`
      create_thumbnail
      create_cropped

      { image: screenshot_file_name, thumbnail: thumbnail_file_name, cropped: cropped_file_name }
    end

    private

    def command_screencapture
      "screencapture #{screenshot_discard_file_path} #{screenshot_file_path}"
    end

    def create_cropped
      CreateCroppedVersion.call(input_file: screenshot_file_path, output_file: cropped_file_path)
    end

    # This should be abstracted to its own class but I'm too tired to do all that typing right now
    def create_thumbnail
      CreateThumbnail.call(input_file: screenshot_file_path, output_file: thumbnail_file_path)
    end

    def cropped_file_name
      "chart-cropped-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}#{'-' if symbol.present?}#{symbol}.png"
    end

    def cropped_file_path
      File.join(NOTE_TAKER_SCREENSHOTS_DIR, 'cropped', cropped_file_name)
    end

    def screenshot_discard_file_path
      @screenshot_discard_file_path = File.join(NOTE_TAKER_SCREENSHOTS_DIR, 'mainscreen-discard.png')
    end

    def screenshot_file_name
      @screenshot_file_name ||= "chart-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}#{'-' if symbol.present?}#{symbol}.png"
    end

    def symbol
      @symbol.gsub('/', 'futures-')
    end

    def thumbnail_file_name
      @thumnnail_file_name ||= "chart-thumbnail-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}#{'-' if symbol.present?}#{symbol}.png"
    end

    def screenshot_file_path
      @screenshot_file_path ||= File.join(NOTE_TAKER_SCREENSHOTS_DIR, 'full_size', screenshot_file_name)
    end

    def thumbnail_file_path
      @thumbnail_file_path ||= File.join(NOTE_TAKER_SCREENSHOTS_DIR, 'thumbnails', thumbnail_file_name)
    end

  end
end