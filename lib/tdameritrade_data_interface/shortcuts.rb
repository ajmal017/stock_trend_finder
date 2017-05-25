module TDAmeritradeDataInterface
  module Shortcuts
    extend self

    # Short cut for add Local Note Taker / Stocktwit note
    def n(message)
      LocalNoteTaker::CreateStocktwitNoteWithScreenshot.(note: message)
    end

    def split(ticker, as_of, shares_given, for_every)
      MarketDataUtilities::Split::AdjustPrices.(
        symbol: ticker,
        as_of_date: as_of,
        given_shares: shares_given,
        for_every_shares: for_every,
      )
    end

    def update_short_interest
      MarketDataUtilities::ShortInterest::Update.call
    end

    def vix_futures_report
      VIXFuturesReport.new.build_report
    end
  end

  extend Shortcuts
end