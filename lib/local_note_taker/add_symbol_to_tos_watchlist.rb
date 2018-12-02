module LocalNoteTaker
  class AddSymbolToTosWatchlist
    include Verbalize::Action

    ACCOUNT_ID = ENV.fetch('TOS_ACCOUNT_ID')
    WATCHLIST_ID = '634270226'
    WATCHLIST_NAME = 'Upside Break/GURM'

    IGNORE_SYMBOLS = %w(
      PORTFOLIO
      SPY
      SVXY
      VXX
    )

    input :symbol

    def call
      return if ignore_symbol?

      client.refresh_access_token
      client.update_watchlist(ACCOUNT_ID, WATCHLIST_ID, WATCHLIST_NAME, symbol)
    end

    private

    def client
      @client ||= TDAmeritrade::Client.new(
        client_id: ENV.fetch('TOS_CLIENT_ID'),
        redirect_uri: ENV.fetch('TOS_REDIRECT_URI'),
        refresh_token: TDAmeritradeToken.get_refresh_token
      )
    end

    def ignore_symbol?
      IGNORE_SYMBOLS.include?(symbol)
    end

  end
end