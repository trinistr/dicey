# frozen_string_literal: true

require_relative "binomial"
require_relative "iterative"
require_relative "multinomial_coefficients"
require_relative "polynomial_convolution"
require_relative "trivial"

module Dicey
  # Calculators for probability distributions of dice.
  #
  # All calculators are subclasses of {BaseCalculator} which implements
  # the core logic and public methods.
  #
  # Following calculators are available:
  # - {Iterative}
  # - {PolynomialConvolution}
  # - {MultinomialCoefficients}
  # - {Empirical} (manual selection only)
  #
  # You will probably want to use {AutoSelector} and not bother
  # with selecting a calculator manually.
  #
  # @example
  #   dice = Dicey::NumericDie.from_list([1, 4, 6], [2, 3, 5])
  #   calculator = Dicey::DistributionCalculators::AutoSelector.call(dice)
  #   calculator&.call(dice) or raise
  module DistributionCalculators
    # Tool to automatically select a calculator for a given set of dice.
    #
    # Calculator is guaranteed to be compatible, with a strong chance of being the most performant.
    #
    # @see BaseCalculator#heuristic_complexity
    class AutoSelector
      # Calculators to consider when selecting a match.
      AVAILABLE_CALCULATORS = [
        Trivial.new,
        Binomial.new,
        PolynomialConvolution.new,
        MultinomialCoefficients.new,
        Iterative.new,
      ].freeze

      # (see #call)
      # Uses shared {INSTANCE} for calls.
      def self.call(dice)
        INSTANCE.call(dice)
      end

      # @param calculators [Array<BaseCalculator>]
      #   calculators which this instance will consider
      def initialize(calculators = AVAILABLE_CALCULATORS)
        @calculators = calculators
      end

      # Instance to be used through {.call}.
      INSTANCE = new.freeze # rubocop:disable Layout/ClassStructure
      # Have to call .new after defining #initialize.

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
