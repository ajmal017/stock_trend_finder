class StocktwitHashtag < ActiveRecord::Base
  belongs_to :stocktwit

  class << self
    def rename(old_hashtag, new_hashtag)
      self.where(tag: old_hashtag).update_all(tag: new_hashtag)
    end
  end
end
