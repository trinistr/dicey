# frozen_string_literal: true

require_relative "hash_formatter"

module Dicey
  module OutputFormatters
    # Formats a hash as a JSON document under +results+ key, with optional +description+ key.
    class JSONFormatter < HashFormatter
      METHOD = :to_json
    end
  end
end
