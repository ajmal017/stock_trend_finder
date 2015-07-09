class VIXFuturesHistory < ActiveRecord::Base
  include Capybara::DSL

  FUTURES_SYMBOLS=['^VIXJAN','^VIXFEB', '^VIXMAR','^VIXAPR','^VIXMAY','^VIXJUN','^VIXJUL','^VIXAUG','^VIXSEP','^VIXOCT','^VIXNOV','^VIXDEC']
  VIXCENTRAL_URL='http://www.vixcentral.com/'

  serialize :futures_curve

  def self.import_vix_futures(screenshot=false)
    starting_month = TDAmeritradeDataInterface.next_vix_futures_symbol
    f = FUTURES_SYMBOLS * 2
    f = f.drop(f.index(starting_month)).take(8) # take the first 10 symbols beginning with the starting month

    futures_curve = f.inject({}) do |futures_curve, symbol|
      quote = Ystock.get_quote(symbol)
      if quote.is_a?(Hash) && quote.has_key?(:price)
        futures_curve[symbol] = quote[:price].to_f
        futures_curve
      end
    end

    each_future = futures_curve.to_a
    contango = ((each_future[1][1] / each_future[0][1]) - 1) * 100

    vix = import_vix

    vfh = VIXFuturesHistory.create(snapshot_time: Time.now, VIX: vix, contango_percent: contango, futures_curve: futures_curve)

    if screenshot
      vfh.update(screenshot_filename: import_vix_curve_screenshot)
    end
  end

  def self.import_vix
    vix = Ystock.get_quote('^VIX')
    vix.has_key?(:price) ? vix[:price].to_f : 0
  end

  def self.import_vix_curve_screenshot
    Capybara.visit VIXCENTRAL_URL
    sleep(7)
    Capybara.save_screenshot(File.join(Rails.root, 'downloads', 'vixcentral_screenshots', next_screenshot_file))
  end

  private

  def self.next_screenshot_file
    "vixcentral_#{Time.now.strftime('%Y-%m-%d_%H%M%S')}.png"
  end
end
