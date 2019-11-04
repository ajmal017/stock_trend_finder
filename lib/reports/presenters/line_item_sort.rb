# TODO Replace this class with a database-level sort mechanism

module Reports
  module Presenters
    class LineItemSort
      include Verbalize::Action

      input :line_items, :sort_field, optional: [:sort_direction]

      def call
        sort_field.is_a?(Array) ? sort_based_on_array : sort_based_on_single_field
      end

      private

      def bubble_sort(items, field, direction)
        n = items.length
        d = direction == :desc ? -1 : 1
        loop do
          swapped = false

          (n-1).times do |i|
            if fv(items[i][field]) * d > fv(items[i+1][field]) * d
              items[i], items[i+1] = items[i+1], items[i]
              swapped = true
            end
          end

          break if not swapped
        end

        items
      end

      def default_sort_direction
        sort_field==:week_52_streak ? :asc : :desc
      end

      def is_number?(value)
        !value.to_f.nil?
      end

      # formatted value
      def fv(value)
        is_number?(value) ? value&.to_f : value
      end

      def sort_based_on_array
        sort_field.reduce(line_items) do |sorted_line_items, sf|
          bubble_sort(sorted_line_items, sf[:field], sf[:direction])
        end
      end

      def sort_based_on_single_field
        sort(line_items, sort_field, sort_direction)
      end

      def sort(items_to_sort, field, direction)
        if direction==:desc
          items_to_sort.sort { |li_a, li_b| (fv(li_b[field]) || 0)<=>(fv(li_a[field]) || 0) }
        else
          items_to_sort.sort { |li_a, li_b| (fv(li_a[field]) || 0)<=>(fv(li_b[field]) || 0) }
        end
      end

      def sort_direction
        @sort_direction || default_sort_direction
      end

    end
  end
end