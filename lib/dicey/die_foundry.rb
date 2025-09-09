# frozen_string_literal: true

require_relative "numeric_die"
require_relative "regular_die"

module Dicey
  # Helper class to define die definitions and automatically select the best one.
  class DieFoundry
    # Regexp for matching a count (or just a positive integer).
    COUNT = /[1-9]\d*+/

    # Possible molds for the dice. They are matched in the order as written.
    MOLDS = [
      # Positive integer goes into the RegularDie mold.
      [/\A(?:(?<count>#{COUNT})?d)?+(?<sides>#{COUNT})\z/i, :regular_mold],
      # List of numbers goes into the NumericDie mold.
      [/\A\(?(?<sides>-?\d++(?>,(?>-?\d++)?)*)\)?\z/i, :weirdly_shaped_mold],
      # Non-integers require arbitrary precision arithmetic, which is not enabled by default.
      [/\A\(?(?<sides>-?\d++(?>\.\d++)?(?>,(?>-?\d++(?>\.\d++)?)?)*)\)?\z/i, :weirdly_precise_mold],
      # Anything else is spilled on the floor.
    ].freeze

    # Cast a die definition into a mold to make a die.
    #
    # Following definitions are recognized:
    # - positive integer (like "6" or "20"), which produces a {RegularDie};
    # - list of integers (like "3,4,5", "(-1,0,1)", or "2,"), which produces a {NumericDie};
    # - list of decimal numbers (like "0.5,0.2,0.8"), which produces a {NumericDie},
    #   but uses +BigDecimal+ for values to maintain precise results.
    #
    # Regular die definition can be prefixed with a count, like "2d6" or "1D3" to create an array.
    # A plain "d" (or "D") without an explicit count is ignored instead, creating a single die.
    #
    # @param definition [String] die shape, refer to {MOLDS} for possible variants
    # @return [NumericDie, RegularDie]
    # @raise [DiceyError] if no mold fits the definition
    def call(definition)
      matched, name =
        MOLDS.reduce(nil) do |_, (shape, mold)|
          match = shape.match(definition)
          break [match, mold] if match
        end
      return broken_mold(definition) unless name

      __send__(name, matched)
    end

    alias cast call

    private

    def regular_mold(definition)
      sides = definition[:sides].to_i
      count = definition[:count]
      if count
        RegularDie.from_count(count.to_i, sides)
      else
        RegularDie.new(sides)
      end
    end

    def weirdly_shaped_mold(definition)
      sides = definition[:sides].split(",").map(&:to_i)
      NumericDie.new(sides)
    end

    def weirdly_precise_mold(definition)
      require "bigdecimal" unless defined?(BigDecimal)

      sides = definition[:sides].split(",").map { BigDecimal(_1) }
      NumericDie.new(sides)
    end

    def broken_mold(definition)
      raise DiceyError, "can not cast die from `#{definition}`!"
    end
  end
end
