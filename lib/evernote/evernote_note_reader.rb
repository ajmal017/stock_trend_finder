require 'evernote_oauth'

module Evernote
  class EvernoteNoteReader
    NOTEBOOK_GUID = '48d890bc-3915-4efd-8387-1c853a6d4835' # Charts, IU, Trade Logs
    MAX_NOTES = 250
    SORT_ORDER = Evernote::EDAM::Type::NoteSortOrder::UPDATED

    def self.get_note_titles
      authToken = ENV['EVERNOTE_DEVELOPER_TOKEN']
      client = EvernoteOAuth::Client.new(token: authToken, sandbox: false)
      ns = client.note_store

      nf = Evernote::EDAM::NoteStore::NoteFilter.new(notebookGuid: NOTEBOOK_GUID, order: SORT_ORDER, ascending: false)
      rs = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new(includeTitle: true)
      notes = ns.findNotesMetadata(authToken, nf, 0, MAX_NOTES, rs)
      notes.notes.map(&:title)
    end

    # Builds a list of tickers from the notes, using notes created in the last X days
    def self.build_ticker_list(days_back)
      note_metadata = self.get_note_titles
      note_metadata = note_metadata.map do |note_title|
        result = {
          title: note_title,
          date: extract_date_from_title(note_title),
          tickers: extract_tickers_from_title(note_title)
        }
        result[:date] && result[:tickers].present? ? result : nil
      end.compact

      note_metadata
        .select { |nm| nm[:date] >= (Date.today - days_back) }
        .flat_map { |nm| nm[:tickers] }
        .uniq
        .sort
    end

    private

    def self.extract_date_from_title(title)
      m = title.match /\d\d\d\d-\d\d-\d\d/
      m ? Date.parse(m[0]) : nil
    end

    def self.extract_tickers_from_title(title)
      result = []
      title.scan(/([A-Z]+)/) { |m| result << m.first }
      result
    end

  end
end