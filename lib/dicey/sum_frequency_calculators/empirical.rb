# frozen_string_literal: true

require_relative "base_calculator"

module Dicey
  module SumFrequencyCalculators
    # "Calculator" for a collection of {NumericDie} using empirically-obtained statistics.
    #
    # @note This calculator is mostly a joke. It can be still be useful for educational purposes,
    #   or to verify results of {BruteForce} when in doubt. It is not used by default.
    #
    # Does +n+ rolls ({N} by default) and calculates approximate probabilities from that.
    # Even if frrequencies are requested, results are non-integer.
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
        statistics.transform_values { (_1 * total_results).fdiv(rolls) }
      end

      def verify_result(*)
        # Ignore verification, as this is inherently imprecise.
        true
      end
    end
  end
end
