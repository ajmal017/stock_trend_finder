require 'evernote/evernote_note_reader'

module Evernote
  class EvernoteWatchList
    WATCHLIST_ID='497678451'
    DAYS_BACK=30
    EXCLUSION_LIST = ['XIV', 'VIX', 'SVXY', 'UVXY', 'SPY']

    def self.build_evernote_watchlist
      tickers = EvernoteNoteReader.build_ticker_list(DAYS_BACK)
      c = TDAmeritradeApi::Client.new
      c.login
      c.edit_watchlist(listid: WATCHLIST_ID, symbollist: tickers - EXCLUSION_LIST)
    end
  end
end