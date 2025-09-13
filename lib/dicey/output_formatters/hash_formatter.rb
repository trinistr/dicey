# frozen_string_literal: true

module Dicey
  # Processors which turn data to text.
  module OutputFormatters
    # Base formatter for outputting in formats which can be converted from a Hash directly.
    # Can add an optional description into the result.
    # @abstract
    class HashFormatter
      # @param hash [Hash{Object => Object}]
      # @param description [String] text to add to result as an extra key
      # @return [String]
      def call(hash, description = nil)
        hash = hash.transform_keys { to_primitive(_1) }
        hash.transform_values! { to_primitive(_1) }
        output = {}
        output["description"] = description if description
        output["results"] = hash
        output.public_send(self.class::METHOD)
      end

      private

      def to_primitive(value)
        primitive?(value) ? value : value.to_s
      end

      def primitive?(value)
        value.is_a?(Integer) || value.is_a?(Float) || value.is_a?(String)
      end
    end
  end
end
