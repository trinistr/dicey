# frozen_string_literal: true

module Dicey
  module Mixins
    # Mix-in for converting dice with non-numeric sides into dice with +VectorNumber+ sides.
    module VectorizeDice
      private

      # Vectorize non-numeric sides for AbstractDie instances,
      # leaving NumericDie instances unchanged.
      #
      # Check for VectorNumber availability *before* calling.
      #
      # @param dice [Array<AbstractDie>]
      # @return [Array<AbstractDie>] a new array of dice
      def vectorize_dice(dice)
        dice.map do |die|
          next die if NumericDie === die

          sides =
            die.sides_list.map do |side|
              (Numeric === side || VectorNumber === side) ? side : VectorNumber.new([side])
            end
          die.class.new(sides)
        end
      end
    end
  end
end
