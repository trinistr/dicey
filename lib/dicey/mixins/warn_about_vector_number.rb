# frozen_string_literal: true

module Dicey
  module Mixins
    # @api private
    # Mix-in for warning about missing VectorNumber gem.
    module WarnAboutVectorNumber
      private

      def warn_about_vector_number
        warn <<~TEXT
          Dice with non-numeric sides need gem "vector_number" to be present and available.
          If this is intended, please install the gem.
        TEXT
        false
      end
    end
  end
end
