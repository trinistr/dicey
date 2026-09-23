# frozen_string_literal: true

require_relative "abstract_die"
require_relative "numeric_die"
require_relative "regular_die"
require_relative "static_die"

require_relative "mixins/rational_to_integer"

module Dicey
  # Helper to create dice from string definitions.
  # See {#call} and constants for available formats.
  class DieFoundry
    include Mixins::RationalToInteger

    # Special characters disallowed in unquoted strings.
    # @see AbstractDie::STRING_TO_QUOTE
    SPECIAL = %{"',()+−-}

    # Pattern for an integer number.
    INTEGER = "(?:-?\\d++)"
    # Pattern for a possibly fractional number.
    NUMBER = "(?:-?\\d++(?:/\\d++|\\.\\d++)?)"
    # Pattern for an "arbitrary" string or number.
    STRING = %{(?:(?<string>[^#{SPECIAL}]++)|"(?<string>[^",]++)"|'(?<string>[^',]++)')}.freeze
    # Pattern for a number or string (allowing negative numbers).
    VALUE = "(?:#{NUMBER}(?=[,)+−-]|\\z)|#{STRING})".freeze

    # Pattern for matching a possible count.
    COUNT = "(?:(?<count>[1-9]\\d*+)?+[Dd])?+"
    # Pattern for matching an optional constant factor.
    CONSTANT = "(?<constant>(?<sign>[+−-])(?<constant_value>#{NUMBER})|" \
               "(?<sign>\\+)(?<constant_value>#{STRING}))".freeze

    molder = ->(pattern) { /\A#{COUNT}(?:#{pattern}|\(#{pattern}\))#{CONSTANT}?\z/ }

    # Possible molds for the dice. They are matched in the order as written.
    MOLDS = [
      # Positive integer goes into the RegularDie mold.
      [/\A#{COUNT}(?<sides>[1-9]\d*+)#{CONSTANT}?\z/, :regular_mold],
      # Integer range goes into the NumericDie mold.
      [molder.("(?<begin>#{INTEGER})(?:[–—…]|\\.{2,3})(?<end>#{INTEGER})"), :range_mold],
      # List of numbers goes into the NumericDie mold.
      [molder.("(?<sides>#{INTEGER}(?:(?:,#{INTEGER})++,?+|,))"), :weirdly_shaped_mold],
      # Non-integers require special handling for precision.
      [molder.("(?<sides>#{NUMBER}(?:(?:,#{NUMBER})++,?+|,))"), :weirdly_precise_mold],
      # Lists of stuff are broken into AbstractDie.
      [molder.("(?<sides>#{VALUE}(?:(?:,#{VALUE})++,?+|,))"), :cursed_mold],
      # Sign-prefixed value goes into the StaticDie mold.
      [/\A#{COUNT}(?:#{CONSTANT}|\(#{CONSTANT}\))\z/, :static_mold],
      # Anything else is spilled on the floor.
    ].each(&:freeze).freeze

    # Cast a die definition into a mold to make a die.
    #
    # Following definitions are recognized:
    # - positive integer (like "6" or "20"), which produces a {RegularDie};
    # - integer range (like "3—6" or "(-5..5)"), which produces a {NumericDie};
    # - list of integers (like "(3,4,5)", "-1,0,1", or "2,"), which produces a {NumericDie};
    # - list of decimal numbers (like "0.5,0.2,0.8" or "(2.0,)"), which produces a {NumericDie},
    #   but uses +Rational+ for values to maintain precise results;
    # - list of strings, possibly mixed with numbers (like "0.5,asdf" or "(👑,♠️,♥️,♣️,♦️,⚓️)"),
    #   which produces an {AbstractDie} with numbers treated the same as in previous cases,
    #   and other or quoted values treated as Strings.
    # - signed value (like "+3", "-3.6" or "(+ABC)"), which produces a {StaticDie},
    #   non-numeric values are only allowed as positive values;
    #
    # Any die definition can be prefixed with a count, like "2D6" or "1d1,3,5" to create an array.
    # A plain "d"/"D" without an explicit count is ignored instead, creating a single die.
    #
    # All die definitions (aside from plain signed value) can be suffixed with a signed value
    # to add or subtract from the result, like "2D6+3" or "5dA,B,C+C".
    # Only numbers can be subtracted.
    #
    # @param definition [String] die shape
    # @return [AbstractDie, Array<AbstractDie>]
    # @raise [DiceyError] if no mold fits the definition
    def call(definition)
      matched, name =
        MOLDS.find do |(shape, mold)|
          match = shape.match(definition)
          break [match, mold] if match
        end
      raise DiceyError, "can not cast die from `#{definition}`!" unless name

      if matched[:constant] && name != :static_mold
        [__send__(name, matched), static_mold(matched, ignore_count: true)].flatten
      else
        __send__(name, matched)
      end
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
      sides.map! { |side| parse_value(side) }
      build_dice(AbstractDie, definition[:count], sides)
    end

    def static_mold(definition, ignore_count: false)
      value = parse_value(definition[:constant_value])
      value = -value if definition[:sign] != "+"

      build_dice(StaticDie, ignore_count ? nil : definition[:count], value)
    end

    def parse_value(side)
      case side
      when /\A#{INTEGER}\z/o
        side.to_i
      when /\A#{NUMBER}\z/o
        rational_to_integer(Rational(side))
      else
        side.match(STRING)[:string]
      end
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
