# frozen_string_literal: true

require_relative "brute_force"
require_relative "kronecker_substitution"
require_relative "multinomial_coefficients"

module Dicey
  module SumFrequencyCalculators
    # Tool to automatically select a calculator for a given set of dice.
    #
    # Calculator is guaranteed to be compatible, with a strong chance of being the most performant.
    #
    # @see BaseCalculator#heuristic_complexity
    class AutoSelector
      # Calculators to consider when selecting a match.
      AVAILABLE_CALCULATORS = [
        KroneckerSubstitution.new,
        MultinomialCoefficients.new,
        BruteForce.new,
      ].freeze

      # @param calculators [Array<BaseCalculator>]
      #   calculators which this instance will consider
      def initialize(calculators = AVAILABLE_CALCULATORS)
        @calculators = calculators
      end

      # Determine best (or adequate) calculator for a given set of dice
      # based on heuristics from the list of available calculators.
      #
      # @param dice [Enumerable<NumericDie>]
      # @return [BaseCalculator, nil] +nil+ if no calculator is compatible
      def call(dice)
        compatible = @calculators.select { _1.valid_for?(dice) }
        return if compatible.empty?

        compatible.min_by { _1.heuristic_complexity(dice) }
      end
    end
  end
end
