module MarketDataPull; module Nasdaq; module InstitutionalHoldings
  class SaveOwnershipSnapshotForSymbol
    include Verbalize::Action

    input :symbol

    def call
      InstitutionalOwnershipSnapshot.find_or_create_by(data)
      Ticker.find_by(symbol: symbol).update(institutional_holdings_percent: data['SharesOutstandingPCT'])
    end

    private

    def data
      pulled_data.merge(ticker_symbol: symbol, scrape_date: Date.current)
    end

    def pulled_data
      @data ||= PullForSymbol.call(symbol: symbol).value
    end


  end
end; end; end