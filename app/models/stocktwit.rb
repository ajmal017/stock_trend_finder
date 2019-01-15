require 'stocktwits_api'

class Stocktwit < ActiveRecord::Base
  FIRST_TWIT_ID=18772403
  ATTEMPTS=3

  has_many :stocktwit_tickers # Keeping this separate from the Tickers table because there may be tickers encountered on ST not in the table
  has_many :stocktwit_hashtags

  enum call_result: { no_call: 0, correct: 1, incorrect: 2, partial: 3 }

  scope :showing, -> (user_id='greenspud') { where(hide: false, stocktwits_user_name: user_id) }

  def self.rename_symbol(old_symbol, new_symbol)
    Stocktwit.where(symbol: old_symbol).update_all(symbol: new_symbol)
    StocktwitTicker.where(ticker_symbol: old_symbol).update_all(ticker_symbol: new_symbol)
    StocktwitWatchTicker.where(ticker_symbol: old_symbol).update_all(ticker_symbol: new_symbol)
  end

  def self.ticker_list(order_by='ticker_symbol', user_id='greenspud')
    ActiveRecord::Base.connection.execute(ticker_list_sql(order_by, user_id))
  end

  def self.setup_list
    StocktwitHashtag.group(:tag).count(:tag).sort { |tag_a, tag_b| tag_b[0] <=> tag_a[0] }
  end

  def self.watching_list
    ActiveRecord::Base.connection.execute(watching_list_sql)
  end

  def self.watching?(symbol)
    StocktwitWatchTicker.find_by(ticker_symbol: symbol).present? && StocktwitWatchTicker.find_by(ticker_symbol: symbol).watching?
  end

  def self.toggle_watching(symbol)
    swt = StocktwitWatchTicker.find_by(ticker_symbol: symbol)
    if swt.present?
      swt.update(watching: !swt.watching)
    else
      swt = StocktwitWatchTicker.create(ticker_symbol: symbol, watching: true)
    end
    @result = swt.watching
  end

  def parse_hashtags!
    message.scan(/(?:\s)(#\S*)/).each do |hashtag|
      hashtag = hashtag.first
      stocktwit_hashtags.create(tag: hashtag) if stocktwit_hashtags.find_by(tag: hashtag).nil?
    end
  end

private

  def self.ticker_list_sql(order_by, user_id)
    <<SQL
    select tx.ticker_symbol, current_date - date_trunc('day', max(stocktwit_time)) as last_updated, max(stocktwit_time) as last_updated_date, count(st.symbol) as count, coalesce(watching, false) as watching
    from stocktwit_tickers tx 
    inner join stocktwits st on tx.stocktwit_id=st.id
    left join stocktwit_watch_tickers tw on tw.ticker_symbol=tx.ticker_symbol
    where
    stocktwits_user_name='#{user_id}' and
    st.hide=false
    group by tx.ticker_symbol, watching
    order by #{order_by}
SQL
  end

  def self.watching_list_sql
    <<SQL
    select swt.ticker_symbol, swt.watching, current_date - date_trunc('day', max(stocktwit_time)) as last_updated, count(st.ticker_symbol)
    from stocktwit_watch_tickers swt inner join stocktwit_tickers st on swt.ticker_symbol=st.ticker_symbol
    inner join stocktwits s on s.id=st.stocktwit_id
    where swt.watching
    group by swt.ticker_symbol, swt.watching
    order by last_updated
SQL
  end
end
