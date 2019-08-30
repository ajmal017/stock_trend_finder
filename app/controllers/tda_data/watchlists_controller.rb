module TDAData
  class WatchlistsController < TDADataControllerBase

    def add_symbol
      binding.pry
      ::TDA::Watchlists::AddSymbolsToWatchlist.call(symbols: [params['symbol']])
      render status: :ok, nothing: true
    end

  end
end
