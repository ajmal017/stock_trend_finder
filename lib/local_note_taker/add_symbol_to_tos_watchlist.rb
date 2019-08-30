module LocalNoteTaker
  class AddSymbolToTosWatchlist
    include Verbalize::Action

    TOS_LOCAL_API_URL = "#{ENV.fetch('TOS_LOCAL_SERVER')}/tda_data/watchlists/symbol"

    IGNORE_SYMBOLS = %w(
      PORTFOLIO
      SSO
      SPXL
      SPY
      SVXY
      TLT
      VXX
      VXXB
      UVXY
    )

    input :symbol

    def call
      return if ignore_symbol?
      HTTParty.post(TOS_LOCAL_API_URL, query: { secret: ENV['TOS_LOCAL_SECRET'], symbol: symbol })
    end

    private

    def ignore_symbol?
      IGNORE_SYMBOLS.include?(symbol)
    end

  end
end