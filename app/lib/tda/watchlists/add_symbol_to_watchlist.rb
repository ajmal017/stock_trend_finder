module TDA; module Watchlists
  class AddSymbolsToWatchlist
    include OAuthAPICall
    include Verbalize::Action

    ACCOUNT_ID = ENV.fetch('TOS_ACCOUNT_ID')
    WATCHLISTS = [
      { watchlist_id: '1214745853', watchlist_name: 'StocktwitsApp' },
    # { watchlist_id: '1175279388', watchlist_name: 'Previous Trades' },
    ]

    input :symbols

    def call
      perform_api_request do |client|
        client.update_watchlist(
          ACCOUNT_ID, WATCHLISTS.first[:watchlist_id], WATCHLISTS.first[:watchlist_name], symbols
        )
      end
    end
  end
end; end