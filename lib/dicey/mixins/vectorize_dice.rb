# frozen_string_literal: true

module Dicey
  module Mixins
    # @api private
    # Mix-in for converting dice with non-numeric sides into dice with +VectorNumber+ sides.
    module VectorizeDice
      private

      # Vectorize non-numeric sides for AbstractDie instances,
      # leaving NumericDie instances unchanged.
      #
      # If +VectorNumber+ is not available, returns the original dice.
      #
      # @param dice [Array<AbstractDie>, AbstractDie]
      # @return [Array<AbstractDie>, AbstractDie] dice with vectorized sides
      def vectorize_dice(dice)
        return dice unless defined?(VectorNumber)
        return vectorize_die_sides(dice) if AbstractDie === dice

        dice.map { vectorize_die_sides(_1) }
      end

      def vectorize_die_sides(die)
        return die if NumericDie === die

        die.class.new(
          die.sides_list.map do |side|
            (Numeric === side || VectorNumber === side) ? side : VectorNumber.new([side])
          end
        )
      end
    end
  end
end
