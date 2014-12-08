require 'stocktwits_api'

class Stocktwit < ActiveRecord::Base
  FIRST_TWIT_ID=18772403

  scope :showing, -> { where(hide: false).order(id: :desc) }

  def self.ticker_list(order_by='symbol')
    ActiveRecord::Base.connection.execute(ticker_list_sql(order_by))
  end

  def self.watching_list
    ActiveRecord::Base.connection.execute(watching_list_sql)
  end

  def self.watching?(symbol)
    twit = Stocktwit.where(symbol: symbol).where("watching IS NOT NULL").order(stocktwit_time: :desc)
    !twit.empty? && twit.first.watching
  end

  def self.toggle_watching(symbol)
    twit = Stocktwit.where(symbol: symbol).order(stocktwit_time: :desc).last
    twit.update(watching: !Stocktwit.watching?(symbol))
    @result = twit.watching
  end

  def self.sync_twits
    attempt = 1
    messages_synced = 0
    while attempt < 3
      since_id = Stocktwit.maximum(:stocktwit_id) || FIRST_TWIT_ID
      begin
        r = StockTwits.get_user_stream('greenspud', since: since_id)
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
          m['symbols'].each do |s|
            Stocktwit.create(
                stocktwit_id: m['id'],
                stocktwit_time: DateTime.parse(m['created_at']),
                stocktwit_url: m['entities'] ? m['entities']['chart']['url'] : nil,
                symbol: s['symbol'],
                message: m['body'],
                image_thumb_url: m['entities'] ? m['entities']['chart']['thumb'] : nil,
                image_large_url: m['entities'] ? m['entities']['chart']['large'] : nil,
                image_original_url: m['entities'] ? m['entities']['chart']['original'] : nil,
                hide: false
            )
          end if m['symbols']
          messages_synced += 1
        end

        break if !cursor['more']
        attempt = 1
      rescue Exception => e
        puts "Error syncing StockTwits, attempt #{attempt}: #{e.message}"
        attempt += 1
      end
    end
    puts "Synced #{messages_synced} messages"
  end

private

  def self.ticker_list_sql(order_by)
    <<SQL
    select symbol, current_date - date_trunc('day', max(stocktwit_time)) as last_updated, max(stocktwit_time) as last_updated_date, count(symbol) as count
    from stocktwits
    group by symbol
    order by #{order_by}
SQL
  end

  def self.watching_list_sql
    <<SQL
with symbols as (
select symbol from stocktwits group by symbol order by symbol
)
select
s.symbol, st.watching, st.stocktwit_time, st.updated_at, current_date - date_trunc('day', stocktwit_time) as last_updated
from symbols s inner join stocktwits st on st.symbol=s.symbol
where
st.watching and
st.stocktwit_time = (select stocktwit_time from stocktwits su where su.symbol=s.symbol and su.watching is not null order by stocktwit_time desc limit 1)
order by stocktwit_time
SQL
  end
end
