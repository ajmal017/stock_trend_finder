# TODO Replace this class with a database-level sort mechanism

module Reports
  module Presenters
    class LineItemSort
      include Verbalize::Action

      input :line_items, :sort_field, optional: [:sort_direction]

      def call
        if sort_direction==:desc
          line_items.sort { |li_a, li_b| (li_b[sort_field] || 0)<=>(li_a[sort_field] || 0) }
        else
          line_items.sort { |li_a, li_b| (li_a[sort_field] || 0)<=>(li_b[sort_field] || 0) }
        end
      end

      private

      def sort_direction
        @sort_direction || :asc
      end

    end
  end
end