require 'open-uri'
require 'concerns/tickers/tags'

class Ticker < ActiveRecord::Base
  include Tags

  has_many :daily_stock_prices
  has_many :stock_splits
  has_many :dividends
  has_many :gap_ups
  has_many :real_time_quotes
  has_many :gap_up_simulation_trades
  has_many :trade_positions
  has_many :minute_stock_prices
  validates_uniqueness_of :symbol

  CATEGORY_TAGS={
      # 100's: Momentum trading stocks
      biotech: 100,
      cybersecurity: 101,
      momo_tech: 102,

      # 200's: China
      china: 201,

      # 300's: Anything oil and gas related
      oil_exploration: 300,
      oil_drilling: 310,

      # 400's: Stocks I would own for the dividend
      utility: 400,
      healthcare_reit: 430,
      oil_mlp: 450,
      consumer_products: 490,

      # 900's: healthcare stocks
      healthcare_insurer: 900,
      drug_distributor: 901,
      healthcare_service_provider: 902,

      drugstore: 910,
  }

  scope :watching, ->{ where(scrape_data: true) }

  enum category_tag: CATEGORY_TAGS

  def self.scrape?(symbol)
    Ticker.find_by(symbol: symbol).scrape_data
  end

  def self.scrape(*symbols)
    symbols.each do |symbol|
      Ticker.find_by(symbol: symbol).update!(scrape_data: true)
    end
  end

  def self.unscrape(*symbols)
    symbols.each do |symbol|
      Ticker.find_by(symbol: symbol).update!(scrape_data: false)
    end
  end

  def self.float(symbol)
    Ticker.find_by(symbol: symbol).float.to_s
  end

  def self.avg_volume(symbol)
    DailyStockPrice.where(ticker_symbol: symbol).order(price_date: :desc).first.average_volume_50day.to_s
  end

  def self.add(symbol, company_name, exchange)
    raise Exception.new("Invalid exchange") if ['nasdaq', 'nyse'].index(exchange).nil?
    Ticker.create(symbol: symbol, company_name: company_name, exchange: exchange, scrape_data:true)
  end

  # SAMPLE OF INPUT (tab delimited):
  # Company Name	Symbol	Market	Price	Shares	Offer Amount	Expected IPO Date
  # JUNO THERAPEUTICS, INC.	JUNO	NASDAQ	15.00-18.00	9,250,000	$191,475,000	12/19/2014
  # FIRST GUARANTY BANCSHARES, INC.		NASDAQ	19.00-21.00	4,571,428	$110,399,982	12/19/2014
  # BELLICUM PHARMACEUTICALS, INC	BLCM	NASDAQ	15.00-17.00	6,250,000	$122,187,500	12/18/2014
  # RICE MIDSTREAM PARTNERS LP	RMP	New York Stock Exchange	19.00-21.00	25,000,000	$603,750,000	12/17/2014
  # ON DECK CAPITAL INC	ONDK	New York Stock Exchange	16.00-18.00	10,000,000	$207,000,000	12/17/2014
  # HORTONWORKS, INC.	HDP	NASDAQ	12.00-14.00	6,000,000	$96,600,000	12/12/2014
  # METALDYNE PERFORMANCE GROUP INC.	MPG	New York Stock Exchange	18.00-21.00	15,384,615	$371,538,447	12/12/2014
  # AVOLON HOLDINGS LTD	AVOL	New York Stock Exchange	21.00-23.00	13,636,363	$360,681,814	12/12/2014
  # NEW RELIC INC	NEWR	New York Stock Exchange	20.00-22.00	5,000,000	$126,500,000	12/12/2014
  # WORKIVA LLC	WK	New York Stock Exchange	13.00-15.00	7,200,000	$124,200,000	12/12/2014
  # CONNECTURE INC	CNXR	NASDAQ	12.00-14.00	5,769,231	$92,884,624	12/12/2014
  # MOMO INC.	MOMO	NASDAQ	12.50-14.50	16,000,000	$266,800,000	12/11/2014
  # JAMES RIVER GROUP HOLDINGS, LTD.	JRVR	NASDAQ	22.00-24.00	11,000,000	$303,600,000	12/11/2014
  # POLAR STAR REALTY TRUST INC.	PSRT	New York Stock Exchange	10.00-13.00	43,478,261	$650,000,000	12/11/2014
  # LENDINGCLUB CORP	LC	New York Stock Exchange	12.00-14.00	57,700,000	$928,970,000	12/11/2014
  def self.add_nasdaq_ticker_list
    log = ''
    File.open(File.join(Rails.root, 'downloads', 'ipo_list.txt'), 'r').each_line do |line|
      company_name,symbol,market,price,shares,offer,ipo_date = line.split("\t")
      case market
        when 'NASDAQ'
          market = 'nasdaq'
        when 'New York Stock Exchange'
          market = 'nyse'
      end

      shares = Float(shares.delete(',')) / 1000

      puts "Creating: #{symbol}, #{company_name}, #{market}, #{shares}"
      log = log + "Creating: #{symbol}, #{company_name}, #{market}, #{shares}\n"
      t = Ticker.find_by(symbol: symbol)
      if t
        puts "Ticker #{symbol} already exists. Resetting scrape flag. Scrape currently #{t.scrape_data}"
        log = log + "Ticker #{symbol} already exists. Resetting scrape flag. Scrape currently #{t.scrape_data}\n"
        t.company_name = company_name
        t.float = shares
        t.exchange = market
        t.scrape_data = true
        t.save!
      else
        Ticker.create(symbol: symbol, company_name: company_name, exchange: market, float: shares, scrape_data:true)
      end

      puts log
    end
  end

  def hide_from_reports(days=1)
    self.update!(hide_from_reports_until: Date.today + days)
  end

end
