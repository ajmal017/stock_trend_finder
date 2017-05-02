module LocalNoteTaker
  class Screenshot
    include Verbalize::Action

    input optional: [:symbol]

    def call
      `#{command}`

      screenshot_file_path
    end

    private

    def command
      "screencapture #{screenshot_discard_file_path} #{screenshot_file_path}"
    end

    def screenshot_discard_file_path
      File.join(NOTE_TAKER_SCREENSHOTS_DIR, 'mainscreen-discard.png')
    end

    def screenshot_file_name
      "chart-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}#{'-' if symbol.present?}#{symbol}.png"
    end

    def screenshot_file_path
      File.join(NOTE_TAKER_SCREENSHOTS_DIR, screenshot_file_name)
    end

  end
end