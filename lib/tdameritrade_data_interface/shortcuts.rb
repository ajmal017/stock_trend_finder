module TDAmeritradeDataInterface
  module Shortcuts
    extend self

    # Short cut for add Local Note Taker / Stocktwit note
    def n(message)
      LocalNoteTaker::CreateStocktwitNoteWithScreenshot.(note: message)
    end

    def vix_futures_report
      VIXFuturesReport.new.build_report
    end
  end

  extend Shortcuts
end