# frozen_string_literal: true

require_relative "key_value_formatter"

module Dicey
  module OutputFormatters
    # Formats a hash as a text file suitable for consumption by Gnuplot.
    #
    # Will transform Rational probabilities to Floats.
    class GnuplotFormatter < KeyValueFormatter
      SEPARATOR = " "

      private

      def transform(key, value)
        [derationalize(key), derationalize(value)]
      end

      def derationalize(value)
        value.is_a?(Rational) ? value.to_f : value
      end
    end
  end
end
