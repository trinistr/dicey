# frozen_string_literal: true

require_relative "numeric_die"
require_relative "regular_die"

require_relative "mixins/rational_to_integer"

module Dicey
  # Helper to create dice from string definitions.
  # See {#call} and constants for available formats.
  class DieFoundry
    include Mixins::RationalToInteger

    # Regexp for matching a possible count.
    PREFIX = /(?:(?<count>[1-9]\d*+)?+d)?+/i
    # Regexp for an integer number.
    INTEGER = /(?:-?\d++)/
    # Regexp for a (possibly) fractional number.
    FRACTION = %r{(?:-?\d++(?:/\d++|\.\d++)?)}
    # Regexp for an "arbitrary" string.
    STRING = /(?:(?<side>[^"',()]++)|"(?<side>[^",]++)"|'(?<side>[^',]++)')/

    # Possible molds for the dice. They are matched in the order as written.
    MOLDS = [
      # Positive integer goes into the RegularDie mold.
      [/\A#{PREFIX}(?<sides>[1-9]\d*+)\z/, :regular_mold].freeze,
      # Integer range goes into the NumericDie mold.
      [/\A#{PREFIX}\(?(?<begin>#{INTEGER})(?:[-–—…]|\.{2,3})(?<end>#{INTEGER})\)?\z/,
       :range_mold].freeze,
      # List of numbers goes into the NumericDie mold.
      [/\A#{PREFIX}\(?(?<sides>#{INTEGER}(?:(?:,#{INTEGER})++,?+|,))\)?\z/,
       :weirdly_shaped_mold].freeze,
      # Non-integers require special handling for precision.
      [/\A#{PREFIX}\(?(?<sides>#{FRACTION}(?:(?:,#{FRACTION})++,?+|,))\)?\z/,
       :weirdly_precise_mold].freeze,
      # Lists of stuff are broken into AbstractDie.
      [/\A#{PREFIX}\(?(?<sides>#{STRING}(?:(?:,#{STRING})++,?+|,))\)?\z/, :cursed_mold].freeze,
      # Anything else is spilled on the floor.
    ].freeze

    # Cast a die definition into a mold to make a die.
    #
    # Following definitions are recognized:
    # - positive integer (like "6" or "20"), which produces a {RegularDie};
    # - integer range (like "3-6" or "(-5..5)"), which produces a {NumericDie};
    # - list of integers (like "(3,4,5)", "-1,0,1", or "2,"), which produces a {NumericDie};
    # - list of decimal numbers (like "0.5,0.2,0.8" or "(2.0,)"), which produces a {NumericDie},
    #   but uses +Rational+ for values to maintain precise results;
    # - list of strings, possibly mixed with numbers (like "0.5,asdf" or "(👑,♠️,♥️,♣️,♦️,⚓️)"),
    #   which produces an {AbstractDie} with strings converted to Symbols
    #   and numbers treated the same as in previous cases.
    #
    # Any die definition can be prefixed with a count, like "2D6" or "1d1,3,5" to create an array.
    # A plain "d" without an explicit count is ignored instead, creating a single die.
    #
    # @param definition [String] die shape
    # @return [AbstractDie, Array<AbstractDie>]
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
      sides = definition[:sides].split(",").map { rational_to_integer(Rational(_1)) }
      build_dice(NumericDie, definition[:count], sides)
    end

    def cursed_mold(definition)
      sides = definition[:sides].split(",")
      sides.map! do |side|
        case side
        when /\A#{INTEGER}\z/o
          side.to_i
        when /\A#{FRACTION}\z/o
          rational_to_integer(Rational(side))
        else
          side.match(STRING)[:side].to_sym
        end
      end
      build_dice(AbstractDie, definition[:count], sides)
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
