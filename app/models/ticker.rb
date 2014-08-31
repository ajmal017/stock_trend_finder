require 'open-uri'
require 'stock_radar'

class Ticker < ActiveRecord::Base
  has_many :daily_stock_prices
  has_many :stock_splits
  has_many :dividends
  has_many :gap_ups
  has_many :real_time_quotes
  has_many :gap_up_simulation_trades
  has_many :trade_positions
  has_many :minute_stock_prices
  validates_uniqueness_of :symbol

  scope :watching, ->{ where(scrape_data: true) }
  scope :tracking_gap_ups, -> { where(track_gap_up: true) }
  scope :russell3000, -> { where(russell3000: true) }

  #def self.last_trading_day
  #  Date.new(2014,1,3)
  #end

  def self.unscrape(*symbols)
    symbols.each do |symbol|
      Ticker.find_by(symbol: symbol).update!(scrape_data: false)
    end
  end

  def self.get_float(symbol)
    Ticker.find_by(symbol: symbol).float.to_s
  end

  def self.update_all_daily_stock_prices
    watching.each do |t|
      t.update_daily_stock_prices
    end
  end

  def latest_split
    (self.stock_splits.map(&:split_date) << (self.daily_stock_prices.minimum(:price_date) || Date.new(2001,9,23))).max
  end





  # deprecated - we no longer use yaho
  #def self.download_real_time_quotes_yahoo
  #  RealTimeQuote.reset_cache
  #
  #  symbols = tracking_gap_ups.pluck(:symbol, :id)
  #  symbol_lookup = Hash[*symbols.flatten]
  #  d=[]
  #  while symbols.present?
  #    lookup_list = symbols.shift(200).map { |symbol, id| symbol}
  #    r = Ystock::Yahoo.quote(lookup_list)
  #
  #    r.each do |quote|
  #      if quote[:symbol].present?
  #        RealTimeQuote.create(
  #            ticker_id: symbol_lookup[quote[:symbol]],
  #            ticker_symbol: quote[:symbol],
  #            last_trade: quote[:price],
  #            open: quote[:open],
  #            high: quote[:day_high],
  #            low: quote[:day_low],
  #            quote_time: Time.now
  #        )
  #      else
  #        puts "Couldnt find #{r}"
  #      end
  #    end
  #
  #    d = d + r
  #  end
  #end

  # this is deprecated bc we no longer use yahoo
  #def download_real_time_quote_yahoo(save_data=false, run_time="")
  #  doc = Nokogiri::HTML(open("http://finance.yahoo.com/q?s=#{symbol}&ql=0"))
  #  price = doc.css("#yfs_l86_#{symbol.downcase}").first # try to get the real time quote price first
  #  if price
  #    price = price.content
  #    quote_time = doc.css("#yfs_t54_#{symbol.downcase}").first.content
  #  else
  #    price = doc.css("#yfs_l84_#{symbol.downcase}").first
  #    if price
  #      price = price.content
  #      quote_time = doc.css("#yfs_t53_#{symbol.downcase}").first.content
  #    end
  #  end
  #  puts "#{price} #{quote_time}"
  #
  #  if price
  #    q = real_time_quotes.new(
  #      ticker_symbol: symbol,
  #      price: price,
  #      quote_time: Time.parse(quote_time)
  #    )
  #    if save_data
  #      q.save!
  #    end
  #    q
  #  end
  #rescue
  #  puts "Error parsing #{ticker_symbol}"
  #end

  # deprecated - we no longer use yahoo
  #def update_daily_stock_prices_yahoo
  #
  #  return if daily_stock_prices.maximum(:price_date) == Ticker.last_trading_day #Date.new(2013,11,29)
  #
  #  if daily_stock_prices.count > 0
  #    begin_date = daily_stock_prices.maximum(:price_date) + 1
  #  else
  #    begin_date = Date.new(2001,9,2)
  #  end
  #
  #  download_file_path = File.join(Rails.root, 'downloads', "#{symbol}_prices_yahoofinance.csv".sub('^', 'v'))
  #  begin
  #    download_file = open(download_file_path, 'w')
  #    download_file.write(open(
  #                            "http://ichart.finance.yahoo.com/table.csv?s=#{symbol}&d=#{Date.today.month-1}&e=#{Date.today.day}&f=#{Date.today.year}&g=d&a=#{begin_date.month-1}&b=#{begin_date.day}&c=#{begin_date.year}&ignore=.csv"
  #                        ).read)
  #    download_file.close
  #  rescue
  #    puts "Error occurred downloading quotes for #{symbol}"
  #  end
  #
  #  db_read_file_path = File.join(Rails.root, 'downloads', 'imports', "#{symbol}_prices_yahoofinance_dbimport.csv".sub('^', 'v'))
  #  if File.exists? download_file_path
  #    puts "Importing #{symbol}..."
  #
  #    download_file = open(download_file_path)
  #    download_file_lines = download_file.readlines
  #    download_file.close
  #
  #    if download_file_lines.length > 0
  #      db_read_file = open(db_read_file_path, 'w')
  #
  #      # Put the column headers on the first line
  #      db_read_file.write("ticker_id,ticker_symbol,price_date,open,high,low,close,volume\n")
  #      #Remove the header from the input file
  #      download_file_lines.shift if download_file_lines[0].match(/Date/).length > 0
  #
  #      puts "Reformatting data in  #{db_read_file_path}"
  #      while download_file_lines.count > 0
  #        price_date,open,high,low,close,volume,adj_close=download_file_lines.pop.split(',')
  #        line = "#{id},#{symbol},#{price_date},#{open},#{high},#{low},#{close},#{volume}\n"
  #        db_read_file.write(line)
  #      end
  #
  #      db_read_file.close
  #
  #      ActiveRecord::Base.connection.execute(
  #          "COPY daily_stock_prices (ticker_id,ticker_symbol,price_date,open,high,low,close,volume)
  #            FROM '#{db_read_file_path}'
  #            WITH (FORMAT 'csv', HEADER)"
  #      ) if File.exists?(db_read_file_path)
  #
  #    end
  #
  #  end


  #end

end
