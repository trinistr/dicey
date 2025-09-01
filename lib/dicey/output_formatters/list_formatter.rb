# frozen_string_literal: true

require_relative "key_value_formatter"

module Dicey
  module OutputFormatters
    # Formats a hash as list of key => value pairs, similar to a Ruby Hash.
    class ListFormatter < KeyValueFormatter
      SEPARATOR = " => "
    end
  end
end
