# frozen_string_literal: true

module Dicey
  module Mixins
    # @api private
    # Mix-in for converting rationals with denominator of 1 to integers.
    module RationalToInteger
      private

      # Convert +value+ to +Integer+ if it's a +Rational+ with denominator of 1.
      # Otherwise, return +value+ as-is.
      #
      # @value [Numeric, Any]
      # @return [Numeric, Integer, Any]
      def rational_to_integer(value)
        (Rational === value && value.denominator == 1) ? value.numerator : value
      end
    end
  end
end
