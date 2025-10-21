# frozen_string_literal: true

module Dicey
  module CLI
    module Formatters
      # Formatter that doesn't format anything and always returns an empty string.
      class NullFormatter
        # @param hash [Hash{Object => Object}]
        # @param description [String] text to add as a comment.
        # @return [String] always an empty string
        def call(hash, description = nil) # rubocop:disable Lint/UnusedMethodArgument
          ""
        end
      end
    end
  end
end
