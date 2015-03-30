require 'stocktwits_api'

class Stocktwit < ActiveRecord::Base
  FIRST_TWIT_ID=18772403

  has_many :stocktwit_tickers # Keeping this separate from the Tickers table because there may be tickers encountered on ST not in the table
  has_many :stocktwit_hashtags

  enum call_result: { no_call: 0, correct: 1, incorrect: 2, partial: 3 }

  scope :showing, -> (user_id='greenspud') { where(hide: false, stocktwits_user_name: user_id).order(id: :desc) }

  def self.ticker_list(order_by='ticker_symbol', user_id='greenspud')
    ActiveRecord::Base.connection.execute(ticker_list_sql(order_by, user_id))
  end

  def self.setup_list
    StocktwitHashtag.group(:tag).count(:tag).sort { |tag_a, tag_b| tag_b[1] <=> tag_a[1] }
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

    # twit = Stocktwit.where(symbol: symbol).order(stocktwit_time: :desc).last
    # twit.update(watching: !Stocktwit.watching?(symbol))
    # @result = twit.watching
  end

  def self.sync_twits
    messages_synced = 0

    ['greenspud', 'traderstewie', 'TraderRL23', 'stt2318', 'starbreakouts', 'chartingManDan', 'Mastertrader_Consultant'].each do |stocktwits_user_name|
      attempt = 1
      while attempt < 3
        since_id = Stocktwit.where(stocktwits_user_name: stocktwits_user_name).maximum(:stocktwit_id) || FIRST_TWIT_ID
        begin
          r = StockTwits.get_user_stream(stocktwits_user_name, since: since_id)
          if r.nil?
            attempt += 1
            next
          end
          if r['response']['status'] != 200
            puts r['response']
            attempt += 1
            next
          end
          break if r['messages'].count == 0

          cursor = r['cursor']
          messages = r['messages'].reverse

          messages.each do |m|
            if m['symbols'] # Not interested in twits that don't talk about a specific ticker
              twit = Stocktwit.create(
                  stocktwit_id: m['id'],
                  stocktwit_time: DateTime.parse(m['created_at']),
                  stocktwit_url: m['entities'] ? m['entities']['chart']['url'] : nil,
                  symbol: m['symbols'].first['symbol'],
                  message: m['body'],
                  image_thumb_url: m['entities'] ? m['entities']['chart']['thumb'] : nil,
                  image_large_url: m['entities'] ? m['entities']['chart']['large'] : nil,
                  image_original_url: m['entities'] ? m['entities']['chart']['original'] : nil,
                  hide: false,
                  stocktwits_user_name: stocktwits_user_name
              )
              m['symbols'].each do |s|
                twit.stocktwit_tickers.create(ticker_symbol: s['symbol'])
              end
              twit.parse_hashtags! if stocktwits_user_name == 'greenspud'
            end
            messages_synced += 1
          end

          break if !cursor['more']
          attempt = 1
        rescue Exception => e
          puts "Error syncing StockTwits, attempt #{attempt}: #{e.message}"
          attempt += 1
        end
      end
    end

    puts "Synced #{messages_synced} messages"
  end

  def self.import_blog_watchlist
    # this is pseudocode - still working on it

    # blog = open 'http://www.greenspudtrades.com/2015/03/05/watchlist-for-3515/'
    # bt = blog.read
    #
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
    select ticker_symbol, current_date - date_trunc('day', max(stocktwit_time)) as last_updated, max(stocktwit_time) as last_updated_date, count(ticker_symbol) as count
    from stocktwit_tickers tx inner join stocktwits st on tx.stocktwit_id=st.id
    where
    stocktwits_user_name='#{user_id}' and
    st.hide=false
    group by ticker_symbol
    order by #{order_by}
SQL
  end

  def self.watching_list_sql
    <<SQL
    select swt.ticker_symbol, swt.watching, current_date - date_trunc('day', max(stocktwit_time)) as last_updated, count(st.ticker_symbol)
    from stocktwit_watch_tickers swt inner join stocktwit_tickers st on swt.ticker_symbol=st.ticker_symbol
    inner join stocktwits s on s.id=st.stocktwit_id
    group by swt.ticker_symbol, swt.watching
    order by last_updated
SQL
  end
end
