module LocalNoteTaker
  class Screenshot
    include Verbalize::Action

    input :ticker, optional: [:symbol]

    def call
      `#{command}`
    end

    private

    def command
      "screencapture #{screenshot_discard_file_path} #{screenshot_file_path}"
    end

    def screenshot_discard_file_path
      File.join(NOTE_TAKER_SCREENSHOTS_DIR, 'mainscreen-discard.png')
    end

    def screenshot_file_name
      "chart-#{Date.today.strftime('%Y%m%d')}#{'-' if symbol.present?}#{symbol}.png"
    end

    def screenshot_file_path
      File.join(NOTE_TAKER_SCREENSHOTS_DIR, screenshot_file_name)
    end

  end
end