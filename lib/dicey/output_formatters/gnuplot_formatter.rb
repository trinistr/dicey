# frozen_string_literal: true

require_relative "key_value_formatter"

module Dicey
  module OutputFormatters
    # Formats a hash as a text file suitable for consumption by Gnuplot.
    class GnuplotFormatter < KeyValueFormatter
      SEPARATOR = " "
    end
  end
end
