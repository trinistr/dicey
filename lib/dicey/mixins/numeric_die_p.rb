# frozen_string_literal: true

module Dicey
  module Mixins
    # @api private
    # Mix-in for checking whether a die is a numeric die
    # more thoroughly than a class check.
    module NumericDieP
      private

      # Check whether +die+ is a NumericDie or has all Numeric sides.
      #
      # @param die [AbstractDie]
      # @return [Boolean]
      def numeric_die?(die)
        NumericDie === die || die.sides_list.all?(Numeric)
      end
    end
  end
end
