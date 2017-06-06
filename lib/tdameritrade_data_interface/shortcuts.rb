module TDAmeritradeDataInterface
  module Shortcuts
    extend self

    # Short cut for add Local Note Taker / Stocktwit note
    def n(message)
      LocalNoteTaker::CreateStocktwitNoteWithScreenshot.(note: message)
    end

    def stocktwit_recent
      Clipboard.copy(
        Stocktwit.ticker_list.select { |t| Date.parse(t['last_updated_date']) > (Date.today - 60)}.map { |t| t['ticker_symbol'] }.join("\n")
      )
    end

    def vix_futures_report
      VIXFuturesReport.new.build_report
    end
  end

  extend Shortcuts
end