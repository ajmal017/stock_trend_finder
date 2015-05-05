class VIXFuturesHistory < ActiveRecord::Base
  FUTURES_SYMBOLS=['^VIXJAN','^VIXFEB', '^VIXMAR','^VIXAPR','^VIXMAY','^VIXJUN','^VIXJUL','^VIXAUG','^VIXSEP','^VIXOCT','^VIXNOV','^VIXDEC']

  serialize :futures_curve

  def self.import_vix_futures
    starting_month = TDAmeritradeDataInterface.next_vix_futures_symbol
    f = FUTURES_SYMBOLS * 2
    f = f.drop(f.index(starting_month)).take(8) # take the first 10 symbols beginning with the starting month

    futures_curve = f.inject({}) do |futures_curve, symbol|
      quote = Ystock::Yahoo.get_quote(symbol)
      if quote.is_a?(Hash) && quote.has_key?(:price)
        futures_curve[symbol] = quote[:price].to_f
        futures_curve
      end
    end

    each_future = futures_curve.to_a
    contango = ((each_future[1][1] / each_future[0][1]) - 1) * 100

    VIXFuturesHistory.create(snapshot_time: Time.now, contango_percent: contango, futures_curve: futures_curve)
  end

end
