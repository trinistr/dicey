# frozen_string_literal: true

module Dicey
  module CLI
    # Processors which turn data to text.
    module Formatters
      # Base formatter for outputting in formats which are map- (or object-) like.
      # Can add an optional description into the result.
      # @abstract
      class BaseMapFormatter
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
          return value if primitive?(value)
          return value.to_f if Numeric === value

          value.to_s
        end

        def primitive?(value)
          value.is_a?(Integer) || value.is_a?(Float) || value.is_a?(String)
        end
      end
    end
  end
end
