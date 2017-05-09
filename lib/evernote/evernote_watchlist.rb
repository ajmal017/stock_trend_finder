require 'evernote/evernote_note_reader'

module Evernote
  class EvernoteWatchList
    WATCHLIST_ID='497678451'
    DAYS_BACK=30
    EXCLUSION_LIST = ['XIV', 'VIX', 'SVXY', 'UVXY', 'SPY']

    def self.build_evernote_watchlist
       EvernoteNoteReader.build_ticker_list(DAYS_BACK) - EXCLUSION_LIST
    end

    def self.copy_evernote_watchlist
      tickers = build_evernote_watchlist
      Clipboard.copy tickers.join("\n")
    end

    def self.upload_evernote_watchlist
      tickers = build_evernote_watchlist
      c = TDAmeritradeApi::Client.new
      c.login
      c.edit_watchlist(listid: WATCHLIST_ID, symbollist: tickers)
    end
  end
end