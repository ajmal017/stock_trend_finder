require 'open-uri'
require 'concerns/tickers/tags'

class Ticker < ActiveRecord::Base
  include Tags
  self.primary_key = 'symbol'

  has_many :daily_stock_prices, foreign_key: 'ticker_symbol', primary_key: 'symbol'
  has_many :dividends
  has_many :minute_stock_prices
  has_many :real_time_quotes
  has_many :stock_splits
  has_many :ticker_notes

  validates_uniqueness_of :symbol

  scope :watching, ->{ where(scrape_data: true) }

  def create_note(note_text='', note_date: Date.today, note_type: nil)
    ticker_notes.create(
                  ticker_symbol: symbol,
                  note_text: note_text,
                  note_date: note_date,
                  note_type: note_type
    )
  end

  def self.removed_tickers
    Ticker.where(on_nasdaq_list: false, scrape_data: true).pluck(:symbol, :company_name).sort {|p1,p2| p1[0]<=>p2[0] }
  end

  def self.rename(original_symbol, new_symbol)
    nt = Ticker.find_or_create_by(symbol: new_symbol)
    raise "Ticker #{new_symbol} #{nt.company_name} already exists!" unless nt.new_record?

    ot = Ticker.find_by(symbol: original_symbol)
    raise "Ticker #{original_symbol} not found" if ot.nil?

    nt_attributes = ot.attributes
    nt_attributes.delete('id')
    nt_attributes.delete('symbol')
    nt.assign_attributes(nt_attributes)
    nt.save!

    Ticker.unscrape(original_symbol)
  end

  def self.scrape?(symbol)
    t = Ticker.find_by(symbol: symbol)
    t.present? && t.scrape_data
  end

  def self.scrape(*symbols)
    symbols.each do |symbol|
      Ticker.find_by(symbol: symbol).update!(scrape_data: true)
    end
  end

  def self.shell_companies
    Ticker.where(scrape_data: true).pluck(:symbol, :company_name).select { |symbol, _company_name| symbol =~ /[A-Z]{4}(W|U|X)/ }
  end

  def self.unscrape(*symbols)
    symbols.each do |symbol|
      Ticker.find_by(symbol: symbol).update!(scrape_data: false, unscrape_date: Date.today)
    end
  end

  def self.unscrape_with_note(symbol, reason)
    t = Ticker.find_by(symbol: symbol)
    t.update(scrape_data: false)
    t.create_note(reason)
  end

  ########### CONVENIENCE METHODS FOR STOCK PROPERTIES ###########

  def self.avg_volume(symbol)
    DailyStockPrice.where(ticker_symbol: symbol).order(price_date: :desc).first.average_volume_50day.to_s
  end

  def self.float(symbol)
    Ticker.find_by(symbol: symbol).float.to_s
  end

  def self.short(symbol)
    t = Ticker.find_by(symbol: symbol).short
  end

  def short
    "#{short_ratio} | #{((short_pct_float || 0) * 100).round}%"
  end

  def self.add(symbol, company_name, exchange)
    raise Exception.new("Invalid exchange") if ['nasdaq', 'nyse'].index(exchange).nil?
    Ticker.create(symbol: symbol, company_name: company_name, exchange: exchange, scrape_data:true)
  end


end
