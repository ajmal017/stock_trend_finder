module TDAmeritradeDataInterface
  module Shortcuts
    extend self

    # Short cut for add Local Note Taker / Stocktwit note
    def n(message)
      LocalNoteTaker::CreateStocktwitNoteWithScreenshot.(note: message)
    end
  end

  extend Shortcuts
end