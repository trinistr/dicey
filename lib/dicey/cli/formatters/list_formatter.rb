# frozen_string_literal: true

require_relative "base_list_formatter"

module Dicey
  module CLI
    module Formatters
      # Formats a hash as list of key => value pairs, similar to a Ruby Hash.
      class ListFormatter < BaseListFormatter
        SEPARATOR = " => "
      end
    end
  end
end
