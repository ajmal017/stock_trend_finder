require 'stocktwits_api'

class Stocktwit < ActiveRecord::Base
  FIRST_TWIT_ID=18772403

  scope :showing, -> (user_id='greenspud') { where(hide: false, stocktwits_user_name: user_id).order(id: :desc) }

  def self.ticker_list(order_by='symbol', user_id='greenspud')
    ActiveRecord::Base.connection.execute(ticker_list_sql(order_by, user_id))
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
                  hide: false,
                  stocktwits_user_name: stocktwits_user_name
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
    end

    puts "Synced #{messages_synced} messages"
  end

private

  def self.ticker_list_sql(order_by, user_id)
    <<SQL
    select symbol, current_date - date_trunc('day', max(stocktwit_time)) as last_updated, max(stocktwit_time) as last_updated_date, count(symbol) as count
    from stocktwits
    where stocktwits_user_name='#{user_id}'
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
s.symbol, st.watching, st.stocktwit_time, st.updated_at, current_date - date_trunc('day', (select stocktwit_time from stocktwits st where st.symbol=s.symbol and st.stocktwits_user_name='greenspud' order by id desc limit 1)) as last_updated, (select count(sc.symbol) from stocktwits sc where sc.symbol=s.symbol) as count
from symbols s inner join stocktwits st on st.symbol=s.symbol
where
st.watching and
st.stocktwit_time = (select stocktwit_time from stocktwits su where su.symbol=s.symbol and su.watching is not null order by stocktwit_time desc limit 1) and
stocktwits_user_name='greenspud'
order by last_updated
SQL
  end
end
