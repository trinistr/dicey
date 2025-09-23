# frozen_string_literal: true

require_relative "base_calculator"

module Dicey
  module SumFrequencyCalculators
    # "Calculator" for a collection of {NumericDie} using empirically-obtained statistics.
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

      def validate(dice)
        dice.all?(NumericDie)
      end

      def calculate(dice, rolls: N)
        statistics = rolls.times.with_object(Hash.new(0)) { |_, hash| hash[dice.sum(&:roll)] += 1 }
        total_results = dice.map(&:sides_num).reduce(:*)
        statistics.transform_values { Rational(_1 * total_results, rolls) }
      end

      def verify_result(*)
        # Ignore verification, as this is inherently imprecise.
        true
      end
    end
  end
end
