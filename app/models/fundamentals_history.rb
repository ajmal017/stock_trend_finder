class FundamentalsHistory < ActiveRecord::Base

  def self.as_of(ticker, date)
    where(ticker_symbol: ticker).where('scrape_date < ?', date).order(scrape_date: :desc).first
  end

end