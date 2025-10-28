# frozen_string_literal: true

require_relative "base_calculator"

require_relative "../mixins/missing_math"
require_relative "../mixins/vectorize_dice"

module Dicey
  module DistributionCalculators
    # Calculator for a collection of equal {AbstractDie} with two sides, like coins,
    # using binomial distribution (very fast).
    #
    # If dice include non-numeric sides, gem +vector_number+ has to be installed.
    class Binomial < BaseCalculator
      include Mixins::MissingMath
      include Mixins::VectorizeDice

      private

      def validate(dice)
        dice.first.sides_num == 2 && dice.all? { _1 == dice.first }
      end

      def calculate_heuristic(dice_count, _sides_count)
        384 * dice_count**2 + 6_760_000
      end

      def calculate(dice, **nil)
        die = vectorize_dice(dice.first)

        coefficients = recurrent_combinations(dice.size)
        first, second = die.sides_list
        sliding_sums(first, second, coefficients)
      end

      def recurrent_combinations(dice_count)
        # Calculating three factorials for each combination is pretty expensive.
        # As the actual formulas just go through factorials in order,
        # we can drastically reduce the complexity by reusing previous values.
        count_factorial = factorial(dice_count)
        index_factorial = 1
        reverse_factorial = count_factorial
        combinations = Array.new(dice_count + 1, 1)
        (1..dice_count).each do |i|
          index_factorial *= i
          reverse_factorial /= (dice_count + 1 - i)
          combinations[i] = count_factorial / (index_factorial * reverse_factorial)
        end
        combinations
      end

      def sliding_sums(side_a, side_b, coefficients)
        length = coefficients.size - 1
        coefficients.each_with_index.with_object({}) do |(coefficient, i), hash|
          outcome = (side_a * (length - i)) + (side_b * i)
          hash[outcome] ||= 0
          hash[outcome] += coefficient
        end
      end
    end
  end
end
