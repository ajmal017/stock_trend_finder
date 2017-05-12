class StocktwitHashtag < ActiveRecord::Base
  belongs_to :stocktwit

  class << self
    def rename(old_hashtag, new_hashtag)
      hashtags_to_rename = self.where(tag: old_hashtag)
      ActiveRecord::Base.transaction do
        hashtags_to_rename.each do |h|
          h.stocktwit.update(message: h.stocktwit.message.gsub(old_hashtag, new_hashtag))
        end
        hashtags_to_rename.update_all(tag: new_hashtag)
      end
    end
  end
end
