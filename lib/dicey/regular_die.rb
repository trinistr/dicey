# frozen_string_literal: true

require_relative "numeric_die"

module Dicey
  # Regular die, which has N sides with numbers from 1 to N.
  #
  # As a subclass of {NumericDie}, enjoys its treatment.
  class RegularDie < NumericDie
    # @param max [Integer] maximum side / number of sides
    def initialize(max)
      unless Integer === max && max.positive?
        raise DiceyError, "regular dice can contain only positive integers, #{max.inspect} is not"
      end

      super((1..max))
    end

    # Return a string representing the die.
    #
    # Regular dice are represented with a "D" followed by the number of sides.
    #
    # @return [String]
    def to_s
      "D#{sides_num}"
    end
  end
end
