module LocalNoteTaker
  module ParseTags

    def parse_hashtags(message)
      message.scan(/#\S*/)
    end

    def parse_symbols(message)
      message.scan(/^[A-Z]+/)
    end

  end
end