# frozen_string_literal: true

require_relative "hash_formatter"

module Dicey
  module OutputFormatters
    # Formats a hash as a YAML document under +results+ key, with optional +description+ key.
    class YAMLFormatter < HashFormatter
      METHOD = :to_yaml
    end
  end
end
