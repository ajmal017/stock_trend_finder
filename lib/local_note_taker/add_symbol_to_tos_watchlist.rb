module LocalNoteTaker
  class AddSymbolToTosWatchlist
    include Verbalize::Action

    ACCOUNT_ID = ENV.fetch('TOS_ACCOUNT_ID')
    WATCHLISTS = [
      { watchlist_id: '1214745853', watchlist_name: 'StocktwitsApp' },
      { watchlist_id: '1175279388', watchlist_name: 'Previous Trades' },
    ]

    IGNORE_SYMBOLS = %w(
      PORTFOLIO
      SSO
      SPXL
      SPY
      SVXY
      VXX
      VXXB
      UVXY
    )

    input :symbol

    def call
      return if ignore_symbol?

      refresh_access_token

      WATCHLISTS.each do |watchlist|
        client.update_watchlist(ACCOUNT_ID, watchlist[:watchlist_id], watchlist[:watchlist_name], symbol)
      end
    end

    private

    def client
      @client ||= TDAmeritradeToken.build_client_from_server_token
    end

    def refresh_access_token
      TDAmeritradeToken.refresh_access_token_and_update_server(client)
    end

    def ignore_symbol?
      IGNORE_SYMBOLS.include?(symbol)
    end

  end
end