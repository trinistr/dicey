# frozen_string_literal: true

module Dicey
  module OutputFormatters
    # Base formatter for outputting lists of key-value pairs separated by newlines.
    # Can add an optional description into the result.
    # @abstract
    class KeyValueFormatter
      # @param hash [Hash{Object => Object}]
      # @param description [String] text to add as a comment.
      # @return [String]
      def call(hash, description = nil)
        initial_string = description ? "# #{description}\n" : +""
        hash.each_with_object(initial_string) do |(key, value), output|
          output << line(transform(key, value)) << "\n"
        end
      end

      private

      def transform(key, value)
        [key, value]
      end

      def line((key, value))
        "#{key}#{self.class::SEPARATOR}#{value}"
      end
    end
  end
end
