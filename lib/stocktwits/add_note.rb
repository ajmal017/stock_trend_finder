module Stocktwits
  class AddNote
    include LocalNoteTaker::ParseTags
    include Verbalize::Action

    input :stocktwit_id, :note_message

    def call
      @twit = Stocktwit.find(stocktwit_id)
      @twit.update(note: note_message)

      hashtags.each { |ht| @twit.stocktwit_hashtags.create(tag: ht) }

      @twit
    end

    private

    def hashtags
      @hashtags ||= parse_hashtags(note_message)
    end

  end
end
