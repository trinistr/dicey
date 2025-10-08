# frozen_string_literal: true

# Try to load "vector_number" pre-emptively.
begin
  require "vector_number"
rescue
  # VectorNumber not available, sad
end

require_relative "base_calculator"

module Dicey
  module SumFrequencyCalculators
    # "Calculator" for a collection of {AbstractDie} using empirically-obtained statistics.
    #
    # @note This calculator is mostly a joke. It can be useful for educational purposes,
    #   or to verify results of {BruteForce} when in doubt. It is not used by default.
    #
    # Does a number of rolls and calculates approximate probabilities from that.
    # Even if frequencies are requested, results are non-integer.
    #
    # *Options:*
    # - *rolls* (Integer) (_defaults_ _to:_ _N_) — number of rolls to perform
    class Empirical < BaseCalculator
      # Default number of rolls to perform.
      N = 10_000

      private

      def calculate(dice, rolls: N)
        dice = vectorize_dice(dice) if defined?(VectorNumber)
        statistics = rolls.times.with_object(Hash.new(0)) { |_, hash| hash[dice.sum(&:roll)] += 1 }
        total_results = dice.map(&:sides_num).reduce(:*)
        statistics.transform_values { Rational(_1 * total_results, rolls) }
      rescue TypeError
        warn <<~TEXT
          Dice with non-numeric sides need gem "vector_number" to be present and available.
          If this is intended, please call `require "vector_number"` before using the calculator.
        TEXT
        raise DiceyError, "attempted to calculate distribution on dice with non-numeric sides",
              cause: nil
      end

      def vectorize_dice(dice)
        dice.map do |die|
          next die if NumericDie === die

          sides = die.sides_list.map { |side| (Numeric === side) ? side : VectorNumber.new([side]) }
          die.class.new(sides)
        end
      end

      def verify_result(*)
        # Ignore verification, as this is inherently imprecise.
        true
      end
    end
  end
end
