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
        case die
        when NumericDie
          die
        when StaticDie
          die.class.new(vectorize_one_die_side(die.value))
        else
          die.class.new(die.sides_list.map { vectorize_one_die_side(_1) })
        end
      end

      def vectorize_one_die_side(side)
        (Numeric === side || VectorNumber === side) ? side : VectorNumber.new([side])
      end
    end
  end
end
