# frozen_string_literal: true

require_relative "base_map_formatter"

module Dicey
  module CLI
    module Formatters
      # Formats a hash as a JSON document under +results+ key, with optional +description+ key.
      class JSONFormatter < BaseMapFormatter
        METHOD = :to_json
      end
    end
  end
end
