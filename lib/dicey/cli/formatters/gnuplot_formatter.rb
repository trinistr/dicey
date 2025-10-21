# frozen_string_literal: true

require_relative "base_list_formatter"

module Dicey
  module CLI
    module Formatters
      # Formats a hash as a text file suitable for consumption by Gnuplot.
      #
      # Will transform Rational probabilities to Floats.
      # Non-numeric dice inherently won't work in gnuplot,
      # even though the formatter will process them.
      class GnuplotFormatter < BaseListFormatter
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
end
