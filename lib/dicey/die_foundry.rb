# frozen_string_literal: true

require_relative "numeric_die"
require_relative "regular_die"

module Dicey
  # Helper class to define die definitions and automatically select the best one.
  class DieFoundry
    # Regexp for matching a possible count.
    PREFIX = /(?>(?<count>[1-9]\d*+)?d)?+/i

    # Possible molds for the dice. They are matched in the order as written.
    MOLDS = [
      # Positive integer goes into the RegularDie mold.
      [/\A#{PREFIX}(?<sides>[1-9]\d*+)\z/, :regular_mold].freeze,
      # Integer range goes into the NumericDie mold.
      [/\A#{PREFIX}\(?(?<begin>-?\d++)(?>[-–—…]|\.{2,3})(?<end>-?\d++)\)?\z/, :range_mold].freeze,
      # List of numbers goes into the NumericDie mold.
      [/\A#{PREFIX}\(?(?<sides>-?\d++(?>,(?>-?\d++)?)+|,)\)?\z/, :weirdly_shaped_mold].freeze,
      # Non-integers require arbitrary precision arithmetic, which is not enabled by default.
      [/\A#{PREFIX}\(?(?<sides>-?\d++(?>\.\d++)?(?>,(?>-?\d++(?>\.\d++)?)?)+|,)\)?\z/,
       :weirdly_precise_mold].freeze,
      # Anything else is spilled on the floor.
    ].freeze

    # Cast a die definition into a mold to make a die.
    #
    # Following definitions are recognized:
    # - positive integer (like "6" or "20"), which produces a {RegularDie};
    # - integer range (like "3-6" or "(-5..5)"), which produces a {NumericDie};
    # - list of integers (like "3,4,5", "(-1,0,1)", or "2,"), which produces a {NumericDie};
    # - list of decimal numbers (like "0.5,0.2,0.8" or "(2.0,)"), which produces a {NumericDie},
    #   but uses +BigDecimal+ for values to maintain precise results.
    #
    # Any die definition can be prefixed with a count, like "2D6" or "1d1,3,5" to create an array.
    # A plain "d" without an explicit count is ignored instead, creating a single die.
    #
    # @param definition [String] die shape
    # @return [NumericDie, RegularDie, Array<NumericDie>, Array<RegularDie>]
    # @raise [DiceyError] if no mold fits the definition
    def call(definition)
      matched, name =
        MOLDS.reduce(nil) do |_, (shape, mold)|
          match = shape.match(definition)
          break [match, mold] if match
        end
      raise DiceyError, "can not cast die from `#{definition}`!" unless name

      __send__(name, matched)
    end

    alias cast call

    private

    def regular_mold(definition)
      build_dice(RegularDie, definition[:count], definition[:sides].to_i)
    end

    def range_mold(definition)
      first = definition[:begin].to_i
      last = definition[:end].to_i
      first, last = last, first if first > last
      build_dice(NumericDie, definition[:count], first..last)
    end

    def weirdly_shaped_mold(definition)
      build_dice(NumericDie, definition[:count], definition[:sides].split(",").map(&:to_i))
    end

    def weirdly_precise_mold(definition)
      require "bigdecimal" unless defined?(BigDecimal)

      sides = definition[:sides].split(",").map { BigDecimal(_1) }
      build_dice(NumericDie, definition[:count], sides)
    end

    def build_dice(die_class, count, sides)
      if count
        die_class.from_count(count.to_i, sides)
      else
        die_class.new(sides)
      end
    end
  end
end
