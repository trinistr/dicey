# frozen_string_literal: true

require_relative "abstract_die"

module Dicey
  # Static die has only one side and always returns the same value.
  # Useful to model constants in dice expressions.
  #
  # @note Unlike other dice, rolling a static die does not advance
  #   shared randomness generator, thus it does not have any impact on
  #   rolling other dice.
  class StaticDie < AbstractDie
    # Die's only value.
    #
    # @return [Any]
    attr_reader :value

    # @param value [Any]
    def initialize(value)
      @value = value
      super([@value].freeze)
    end

    alias current value
    alias next value
    alias roll value

    # Return a string representing the die.
    #
    # Static dice are represented with a "+" or "-" followed by the absolute value
    # (0 is represented as +0). Strings are quoted.
    #
    # @return [String]
    def to_s
      if @value.respond_to?(:negative?) && @value.negative?
        side_to_s(@value)
      else
        "+#{side_to_s(@value)}"
      end
    end
  end
end
