# frozen_string_literal: true

require_relative "numeric_die"

module Dicey
  # Regular die, which has N sides with numbers from 1 to N.
  class RegularDie < NumericDie
    # Characters to use for small dice.
    D6 = "⚀⚁⚂⚃⚄⚅"

    # @param max [Integer] maximum side / number of sides
    def initialize(max)
      unless Integer === max && max.positive?
        raise DiceyError, "regular dice can contain only positive integers, #{max.inspect} is not"
      end

      super((1..max))
    end

    # Dice with 1–6 sides are displayed with a single character from {D6}.
    # More than that, and we get into the square bracket territory.
    #
    # @return [String]
    def to_s
      (sides_num <= D6.size) ? D6[sides_num - 1] : "[#{sides_num}]"
    end
  end
end
