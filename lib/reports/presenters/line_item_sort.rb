# TODO Replace this class with a database-level sort mechanism

module Reports
  module Presenters
    class LineItemSort
      include Verbalize::Action

      input :line_items, :sort_field, optional: [:sort_direction]

      def call
        if sort_direction==:desc
          line_items.sort { |li_a, li_b| (fv(li_b[sort_field]) || 0)<=>(fv(li_a[sort_field]) || 0) }
        else
          line_items.sort { |li_a, li_b| (fv(li_a[sort_field]) || 0)<=>(fv(li_b[sort_field]) || 0) }
        end
      end

      private

      # formatted value
      def fv(value)
        is_number? ? value&.to_f : value
      end

      def sort_direction
        @sort_direction || :asc
      end

      def is_number?
        [:week_52_streak].include?(sort_field)
      end

    end
  end
end