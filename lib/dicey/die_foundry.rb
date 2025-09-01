# frozen_string_literal: true

require_relative "numeric_die"
require_relative "regular_die"

module Dicey
  # Helper class to define die definitions and automatically select the best one.
  class DieFoundry
    # Possible molds for the dice. They are matched in the order as written.
    MOLDS = {
      # Positive integer goes into the RegularDie mold.
      ->(d) { /\A[1-9]\d*\z/.match?(d) } => :regular_mold,
      # List of numbers goes into the NumericDie mold.
      ->(d) { /\A\(?-?\d++(?:,-?\d++)*\)?\z/.match?(d) } => :weirdly_shaped_mold,
      # Real numbers require arbitrary precision arithmetic, which is not enabled by default.
      ->(d) {
        /\A\(?-?\d++(?:\.\d++)?(?:,-?\d++(?:\.\d++)?)*+\)?\z/.match?(d)
      } => :weirdly_precise_mold,
      # Anything else is spilled on the floor.
      ->(*) { true } => :broken_mold,
    }.freeze

    # Regexp for removing brackets from lists.
    BRACKET_STRIPPER = /\A\(?(.+)\)?\z/

    # Cast a die definition into a mold to make a die.
    #
    # @param definition [String] die shape, refer to {MOLDS} for possible variants
    # @return [NumericDie, RegularDie]
    # @raise [DiceyError] if no mold fits the definition
    def cast(definition)
      _shape, mold = MOLDS.find { |shape, _mold| shape.call(definition) }
      __send__(mold, definition)
    end

    private

    def regular_mold(definition)
      RegularDie.new(definition.to_i)
    end

    def weirdly_shaped_mold(definition)
      definition = definition.match(BRACKET_STRIPPER)[1]
      NumericDie.new(definition.split(",").map(&:to_i))
    end

    def weirdly_precise_mold(definition)
      require "bigdecimal"
      definition = definition.match(BRACKET_STRIPPER)[1]
      NumericDie.new(definition.split(",").map { BigDecimal(_1) })
    end

    def broken_mold(definition)
      raise DiceyError, "can not cast die from `#{definition}`!"
    end
  end
end
