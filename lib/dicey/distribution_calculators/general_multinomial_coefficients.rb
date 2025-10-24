# frozen_string_literal: true

require_relative "base_calculator"

require_relative "../mixins/missing_math"

module Dicey
  module DistributionCalculators
    # Calculator for multiple equal regular dice (fast).
    #
    # Example dice: D6, D4, etc.
    #
    # Rolling multiple of the same dice is the same thing as rolling a single die
    # multiple times and summing the results.
    # This arrangement corresponds to a multinomial distribution.
    #
    # The usual way to calculate probabilities for such distribution involves
    # way too many factorials of large numbers for comfort.
    # (`Math.gamma` doesn't even handle large enough numbers, and produces Floats anyway).
    # Instead, we use a Pascal's triangle extension for a higher number of coefficients.
    # This calculator uses a simplified algorithm for regular dice.
    #
    # @see https://en.wikipedia.org/wiki/Multinomial_distribution
    # @see https://en.wikipedia.org/wiki/Pascal's_triangle
    # @see https://en.wikipedia.org/wiki/Trinomial_triangle
    class GeneralMultinomial < BaseCalculator
      include Mixins::MissingMath

      T3 = [
        [1],
        [1, 1, 1],
        [1, 2, 2, 1, 2, 1],
        [1, 3, 3, 3, 6, 3, 1, 3, 3, 1],
        [1, 4, 4, 6, 12, 6, 4, 12, 12, 4, 1],
        [1, 5, 5, 10, 20, 10, 10, 30, 30, 10, 5, 20, 30, 20, 5, 1],
        [1, 6, 6, 15, 30, 15, 20, 60, 60, 20, 15, 60, 90, 60, 15, 6, 30, 60, 60, 30, 6, 1, 6, 15,
         20, 15, 6, 1],
      ].freeze

      private

      def validate(dice)
        first_die = dice.first
        dice.all? { _1 == first_die }
      end

      def calculate_heuristic(dice_count, sides_count)
        500 * (dice_count**2.2) * 500 * (sides_count**1.9)
      end

      def calculate(dice, **nil)
        dice_count = dice.size
        sides_count = dice.first.sides_num

        multinomial_coefficients_num(sides_count, dice_count)
      end

      # Calculate number of coefficients in expansion of (x_1 +...+ x_n)^k.
      #
      # @param n [Integer] number of variables
      # @param k [Integer] power
      # @return [Integer]
      def multinomial_coefficients_num(n, k) # rubocop:disable Naming/MethodParameterName
        return 0 if n.zero?

        combinations(k + n - 1, n - 1)
      end
    end
  end
end
