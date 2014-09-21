require 'open-uri'

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

  def self.get_float(symbol)
    Ticker.find_by(symbol: symbol).float.to_s
  end

  def hide_from_reports(days=1)
    self.update!(hide_from_reports_until: Date.today + days)
  end

  # deprecated for now because I no longer track splits
  # def latest_split
  #   (self.stock_splits.map(&:split_date) << (self.daily_stock_prices.minimum(:price_date) || Date.new(2001,9,23))).max
  # end


end
